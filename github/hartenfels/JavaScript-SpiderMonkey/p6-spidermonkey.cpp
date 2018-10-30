#include <jsapi.h>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
namespace perl6_spidermonkey
{


#ifndef P6SM_VERSION
#   error "You need to set P6SM_VERSION"
#endif

#if P6SM_VERSION <= 24
#   define  P6SM_INIT          /* JS_Init() doesn't exist */
#   define _P6SM_PARAM_THREADS ,JS_USE_HELPER_THREADS
#   define _P6SM_PARAM_FIRE    /* parameter doesn't exist */
#   define  P6SM_ADDRESS(X)    (X).address()
#else
#   define  P6SM_INIT          JS_Init()
#   define _P6SM_PARAM_THREADS /* parameter removed */
#   define _P6SM_PARAM_FIRE    ,JS::FireOnNewGlobalHook
#   define  P6SM_ADDRESS(X)    &(X)
#endif


static JSClass global_class = {
    "global",
    JSCLASS_GLOBAL_FLAGS,
# if P6SM_VERSION < 38
    JS_PropertyStub,
    JS_DeletePropertyStub,
    JS_PropertyStub,
    JS_StrictPropertyStub,
    JS_EnumerateStub,
    JS_ResolveStub,
    JS_ConvertStub,
# endif
};


static JSBool dispatch(JSContext* context, unsigned int argc, JS::Value* vp)
{
    JS::CallArgs args = CallArgsFromVp(argc, vp);

    JSFunction* fun = JS_ValueToFunction(context, args.calleev());
    char* name = JS_EncodeStringToUTF8(context, JS_GetFunctionId(fun));
    std::cerr << name << '\n';
    JS_free(context, name);

    return true;
}


/* Simple auto pointer that calls `delete` on abnormal scope exit. */
template <typename T> class Auto
{
public:
    Auto(T* p) : ptr(p) {}

    ~Auto()         { delete ptr; }
    T* operator->() { return ptr; }
    T* get()        { return ptr; }

    T* ret() /* normal return */
    {
        T* p = ptr;
        ptr  = NULL;
        return p;
    }

private:
    T* ptr;

    Auto<T>           (Auto<T> const&); /* no copying    */
    Auto<T>& operator=(Auto<T> const&); /* no assignment */
};


struct Value
{
    JSContext*      context;
    JS::RootedValue rval;
    char*           strval;


    Value(JSContext* cx) : context(cx), rval(cx), strval(NULL) {}

    Value(JSContext* cx, bool b) : context(cx), rval(cx), strval(NULL)
    {
        rval.setBoolean(b);
    }

    Value(JSContext* cx, double d) : context(cx), rval(cx), strval(NULL)
    {
        rval.setDouble(d);
    }

    Value(JSContext* cx, const jschar* s, unsigned int len)
        : context(cx), rval(cx), strval(NULL)
    {
        /* FIXME: does this leak the JSString? */
        rval.setString(JS_NewUCStringCopyN(context, s, len));
    }

    ~Value()
    {
        JS_free(context, strval);
    }


    const char* type()
    {
        switch (JS_TypeOfValue(context, rval))
        {
            case JSTYPE_VOID    : return "undefined";
            case JSTYPE_OBJECT  : return "object";
            case JSTYPE_FUNCTION: return "function";
            case JSTYPE_STRING  : return "string";
            case JSTYPE_NUMBER  : return "number";
            case JSTYPE_BOOLEAN : return "boolean";
            default             : return NULL;
        }
    }


    const char* str()
    {
        if (!strval)
            strval = JS_EncodeStringToUTF8(context,
                                           JS_ValueToString(context, rval));
        return strval;
    }


    bool num(double* number)
    {
        return JS_ValueToNumber(context, rval, number);
    }


    bool boolean(JSBool* b)
    {
        return JS_ValueToBoolean(context, rval, b);
    }


    bool accessible()
    {
        return rval.isObject() && !rval.isNull();
    }


    JSObject* to_object(const char* fun)
    {
        if (!rval.isObject())
        {
            JS_ReportError(context, "%s: not an object", fun);
            return NULL;
        }

        JSObject* obj;
        if (!JS_ValueToObject(context, rval, &obj))
            return NULL;

        if (!obj)
        {
            JS_ReportError(context, "%s: object is null", fun);
            return NULL;
        }

        return obj;
    }


    Value* at_key(const jschar* key, unsigned int len)
    {
        JSObject* obj = to_object("AT-KEY");
        if (!obj)
            return NULL;

        Auto<Value> out(new Value(context));
        if (JS_GetUCProperty(context, obj, key, len,
            P6SM_ADDRESS(out->rval)))
            return out.ret();

        return NULL;
    }


    Value* at_pos(uint32_t pos)
    {
        JSObject* obj = to_object("AT-POS");

        if (!obj)
            return NULL;

        Auto<Value> out(new Value(context));
        if (JS_GetElement(context, obj, pos, P6SM_ADDRESS(out->rval)))
            return out.ret();

        return NULL;
    }
};


struct Error
{
    bool         handled;
    std::string  message;
    std::string  file;
    unsigned int line;
    unsigned int column;
};


struct Context
{
    JSContext       * context;
    JS::RootedObject* global;
    Error             error;


    Context(JSRuntime* rt, size_t stack_size) : context(NULL), global(NULL)
    {
        error.handled = true;

        context = JS_NewContext(rt, stack_size);
        if (!context)
            throw std::runtime_error("can't create context");

        JS_SetContextPrivate(context, this);
        /* FIXME maybe?
         * JS_SetErrorReport is documented to take a JSRuntime* as its
         * first argument, but it totally doesn't. Maybe it got changed
         * in a later version, in which case this needs to be ifdef'd.
         */
        JS_SetErrorReporter(context, Context::on_error);

        JSObject* gobj = JS_NewGlobalObject(context, &global_class, NULL
                                            _P6SM_PARAM_FIRE);
        global = new JS::RootedObject(context, gobj);
        if (!*global)
            throw std::runtime_error("can't create global object");

        {
            JSAutoCompartment ac(context, *global);

            if (!JS_InitStandardClasses(context, *global))
                throw std::runtime_error("can't initialize standard classes");

            if (!JS_DefineFunction(context, *global, "doit", dispatch, 0, 0))
                throw std::runtime_error("can't register dispatch function");
        }
    }


    ~Context()
    {
        if (context)
        {
            JS_DestroyContext(context);
        }
        delete global;
    }


    Value* eval(const jschar* script, unsigned int len, const char* file, int line)
    {
        Auto<Value> val(new Value(context));
        bool ok;

        {
            JSAutoCompartment ac(context, *global);
#         if P6SM_VERSION < 38
            ok = JS_EvaluateUCScript(context, *global,
#         else
            JS::CompileOptions opts(context);
            opts.setFileAndLine(file, line);
            ok = JS::Evaluate(context, *global, opts,
#         endif
                              script, len, file, line,
                              P6SM_ADDRESS(val->rval));
        }

        return ok ? val.ret() : NULL;
    }


    Value* call(Value* val, Value* self, unsigned int argc, Value** argv)
    {
        JSObject* obj = self->to_object("CALL-ME");
        if (!obj)
            return NULL;

        std::vector<JS::Value> args;
        for (unsigned int i = 0; i < argc; ++i)
            args.push_back(argv[i]->rval.get());

        Auto<Value> out(new Value(context));
        bool ok;

        {
            JSAutoCompartment ac(context, *global);
            ok = JS_CallFunctionValue(context, obj, *P6SM_ADDRESS(val->rval),
                                      argc, argc ? &args[0] : NULL,
                                      P6SM_ADDRESS(out->rval));
        }

        return ok ? out.ret() : NULL;
    }


    static Context* from_js(JSContext* context)
    {
        return static_cast<Context*>(JS_GetContextPrivate(context));
    }


    static void on_error(JSContext* context, const char* msg, JSErrorReport* report)
    {
        if (report->flags & JSREPORT_WARNING)
        {
            std::cerr << msg << '\n';
        }
        else
        {
            Context* cx = Context::from_js(context);
            if (!cx->error.handled)
            {
                std::cerr << "JavaScript::Spidermonkey: Whoa, unhandled error!\n"
                          << cx->error.message << '\n';
            }
            cx->error.handled = false;
            cx->error.message = msg;
            cx->error.file    = report->filename ? report->filename : "";
            cx->error.line    = report->lineno;
            cx->error.column  = report->column;
        }
    }

    Error* get_error()
    {
        if (error.handled)
            return NULL;
        error.handled = true;
        return &error;
    }
};


}


using namespace perl6_spidermonkey;

extern "C"
{
    int p6sm_version()
    {
        return P6SM_VERSION;
    }

    void p6sm_shutdown()
    {
        JS_ShutDown();
    }


    JSRuntime* p6sm_runtime_new(long memory)
    {
        P6SM_INIT;
        return JS_NewRuntime(memory _P6SM_PARAM_THREADS);
    }

    void p6sm_runtime_free(JSRuntime* rt)
    {
        JS_DestroyRuntime(rt);
    }


    const char*  p6sm_error_message(Error* e) { return e->message.c_str(); }
    const char*  p6sm_error_file   (Error* e) { return e->file.c_str();    }
    unsigned int p6sm_error_line   (Error* e) { return e->line;            }
    unsigned int p6sm_error_column (Error* e) { return e->column;          }


    Context* p6sm_context_new(JSRuntime* rt, int stack_size)
    {
        try
        {
            Auto<Context> cx(new Context(rt, stack_size));
            return cx.ret();
        }
        catch(std::runtime_error& e)
        {
            std::cerr << e.what() << '\n';
        }
        return NULL;
    }

    void p6sm_context_free(Context* cx)
    {
        delete cx;
    }

    Error* p6sm_context_error(Context* cx)
    {
        return cx->get_error();
    }

    Value* p6sm_context_eval(Context     * cx,
                             const jschar* script,
                             unsigned int  len,
                             const   char* file,
                             int           line)
    {
        return cx->eval(script, len, file, line);
    }


    Value* p6sm_new_bool_value(Context* cx, int b)
    {
        JSAutoCompartment ac(cx->context, *cx->global);
        return new Value(cx->context, b != 0);
    }

    Value* p6sm_new_num_value(Context* cx, double d)
    {
        JSAutoCompartment ac(cx->context, *cx->global);
        return new Value(cx->context, d);
    }

    Value* p6sm_new_str_value(Context* cx, const jschar* s, unsigned int len)
    {
        JSAutoCompartment ac(cx->context, *cx->global);
        return new Value(cx->context, s, len);
    }



    Context* p6sm_value_context(Value* val)
    {
        return Context::from_js(val->context);
    }

    void p6sm_value_free(Value* val)
    {
        delete val;
    }

    Error* p6sm_value_error(Value* val)
    {
        Context* cx = Context::from_js(val->context);
        return cx->get_error();
    }

    const char* p6sm_value_type(Value* val)
    {
        return val->type();
    }

    const char* p6sm_value_str(Value* val)
    {
        return val->str();
    }

    int p6sm_value_num(Value* val, double* number)
    {
        return val->num(number);
    }

    int p6sm_value_bool(Value* val, int* boolean)
    {
        JSBool b;
        if (val->boolean(&b))
        {
            *boolean = b;
            return 1;
        }
        return 0;
    }

    Value* p6sm_value_call(Value*       val,
                           Value*       self,
                           unsigned int argc,
                           Value**      argv)
    {
        Context* cx = Context::from_js(val->context);
        return cx->call(val, self, argc, argv);
    }

    int p6sm_value_accessible(Value* val)
    {
        return val->accessible();
    }

    Value* p6sm_value_at_key(Value* val, const jschar* key, unsigned int len)
    {
        return val->at_key(key, len);
    }

    Value* p6sm_value_at_pos(Value* val, uint32_t pos)
    {
        return val->at_pos(pos);
    }
}
