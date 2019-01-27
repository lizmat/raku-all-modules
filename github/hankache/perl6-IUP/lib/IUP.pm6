use NativeCall;

sub LOCAL_LIB() { return %?RESOURCES<lib/IUP.so>.Str}
#
# Callback Return Values
#
constant IUP_IGNORE   = -1;
constant IUP_DEFAULT  = -2;
constant IUP_CLOSE    = -3;
constant IUP_CONTINUE = -4;

#
# IupPopup and IupShowXY Parameter Values
#
constant IUP_CENTER       = 0xFFFF;  # 65535
constant IUP_LEFT         = 0xFFFE;  # 65534
constant IUP_RIGHT        = 0xFFFD;  # 65533
constant IUP_MOUSEPOS     = 0xFFFC;  # 65532
constant IUP_CURRENT      = 0xFFFB;  # 65531
constant IUP_CENTERPARENT = 0xFFFA;  # 65530
constant IUP_TOP          = IUP_LEFT;
constant IUP_BOTTOM       = IUP_RIGHT;

#
# Color Space
#
constant IUP_RGB  = 1;
constant IUP_RGBA = 2;

class IUP::Pixmap {
	method load(@data) {
		my $image = CArray[int8].new();
		my $i = 0;
		for @data -> $c {
			if 0 > $c.Int > 255 {
				say "Error loading Pixmap...";
				exit();
			}
			$image[$i++] = $c.Int;
		}
		return $image;
	}
}

class IUP::Callback is repr('CPointer') {}

class IUP::Handle is repr('CPointer') {

	sub p6IupNewChildrenList(int32)
		returns OpaquePointer is native(LOCAL_LIB) { ... };

	sub p6IupAddChildToList(OpaquePointer, IUP::Handle, int32, int32)
		is native(LOCAL_LIB) { ... };

	sub p6IupFree(OpaquePointer)
		is native(LOCAL_LIB) { ... };

	### Callbacks

	sub p6IupSetCallback_void(IUP::Handle, Str, &cb (--> int32))
		returns IUP::Callback is native(LOCAL_LIB) { ... };

	sub p6IupSetCallback_handle(IUP::Handle, Str, &cb (IUP::Handle --> int32))
		returns IUP::Callback is native(LOCAL_LIB) { ... };

	###

	sub IupDestroy(IUP::Handle)
		is native(LOCAL_LIB) { ... };

	sub IupAppend(IUP::Handle $ih, IUP::Handle $child)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupInsert(IUP::Handle $ih, IUP::Handle $ref_child, IUP::Handle $child)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupGetChild(IUP::Handle, int32)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupGetNextChild(IUP::Handle $ih, IUP::Handle $child)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupGetParent(IUP::Handle)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupGetDialog(IUP::Handle)
		returns int32 is native(LOCAL_LIB) { ... };

	###

	sub IupPopup(IUP::Handle, int32, int32)
		returns int32 is native(LOCAL_LIB) { ... };

	sub IupShow(IUP::Handle)
		returns int32 is native(LOCAL_LIB) { ... };

	sub IupShowXY(IUP::Handle, int32, int32)
		returns int32 is native(LOCAL_LIB) { ... };

	sub IupHide(IUP::Handle)
		returns int32 is native(LOCAL_LIB) { ... };

	sub IupMap(IUP::Handle)
		returns int32 is native(LOCAL_LIB) { ... };

	###

	sub IupSetAttribute(IUP::Handle, Str, Str)
		is native(LOCAL_LIB) { ... };

	sub IupStoreAttribute(IUP::Handle, Str, Str)
		is native(LOCAL_LIB) { ... };

	sub IupSetAttributes(IUP::Handle, Str)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupGetAttribute(IUP::Handle, Str)
		returns Str is native(LOCAL_LIB) { ... };

	sub IupGetAttributes(IUP::Handle)
		returns Str is native(LOCAL_LIB) { ... };

	sub IupGetInt(IUP::Handle, Str)
		returns int32 is native(LOCAL_LIB) { ... };

	###

	sub IupSetCallback(IUP::Handle, Str, IUP::Callback)
		returns IUP::Callback is native(LOCAL_LIB) { ... };

	###

	sub IupSetHandle(Str, IUP::Handle)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	###

	sub IupSetAttributeHandle(IUP::Handle $ih, Str $name, IUP::Handle $ih_named)
		is native(LOCAL_LIB) { ... };

	###

	sub IupFill()
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub p6IupVbox(IUP::Handle)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupVboxv(OpaquePointer)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub p6IupHbox(IUP::Handle)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupHboxv(OpaquePointer)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	###

	sub IupFrame(IUP::Handle $child)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	###

	sub IupImage(int32, int32, CArray[int8])
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupImageRGB(int32, int32, CArray[int8])
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupImageRGBA(int32, int32, CArray[int8])
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	###

	sub p6IupItem(Str, Str)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupSubmenu(Str, IUP::Handle)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupSeparator()
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub p6IupMenu(IUP::Handle)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupMenuv(OpaquePointer)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	###

	sub p6IupButton(Str $title, Str $action)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupCanvas(Str $action)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupDialog(IUP::Handle)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub IupLabel(Str)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	sub p6IupText(Str $action)
		returns IUP::Handle is native(LOCAL_LIB) { ... };

	###

	sub IupMessage(Str $title, Str $message)
		is native(LOCAL_LIB) { ... };

	### METHODS ###

	method destroy() {
		IupDestroy(self);
	}

	method append(IUP::Handle $child) {
		return IupAppend(self, $child);
	}

	method insert(IUP::Handle $ref_child, IUP::Handle $child) {
		return IupInsert(self, $ref_child, $child);
	}

	method get_child($position) {
		return IupGetChild(self, $position);
	}

	method get_next_child(IUP::Handle $child) {
		return IupGetNextChild(self, $child);
	}

	method get_parent() {
		return IupGetParent(self);
	}

	method get_dialog() {
		return IupGetDialog(self);
	}

	###

	method popup(Int $x, Int $y) {
		return IupPopup(self, $x, $y);
	}

	multi method show() {
		return IupShow(self);
	}

	multi method show(Int $x, Int $y) {
		return IupShowXY(self, $x, $y);
	}

	method hide() {
		return IupHide(self);
	}

	method map() {
		return IupMap(self);
	}

	###

	# http://www.tecgraf.puc-rio.br/iup/en/func/iupsetattribute.html
	method set_attribute(Str $name, Str $value) {
		#IupSetAttribute(self, $name, $value);
		IupStoreAttribute(self, $name, $value);
	}

	# numeric keys
	multi method set_attributes(*@attributes) {
		my Str @tmp = ();
		for @attributes.values -> $pair {
			my ($name, $value) = $pair.kv;
			push(@tmp, join("=", $name, "\"$value\""));
		}
		my $string = join(", ", @tmp).Str;
		return IupSetAttributes(self, $string);
	}

	multi method set_attributes(*%attributes) {
		my Str @tmp = ();
		for %attributes.kv -> Str $name, $value {
			push(@tmp, join("=", $name, "\"$value\""));
		}
		return IupSetAttributes(self, join(", ", @tmp).Str);
	}

	method get_attribute(Str $name) returns Str {
		return IupGetAttribute(self, $name);
	}

	method get_attributes() returns Str {
		return IupGetAttributes(self);
	}

	method get_int(Str $name) returns Int {
		return IupGetInt(self, $name);
	}

	###

	method set_callback(Str $name, $function) {
		my @params = $function.signature.params;
		given @params.elems {
			when 0 { return p6IupSetCallback_void(self, $name.fmt("%s").Str, $function); }
			when 1 { return p6IupSetCallback_handle(self, $name.fmt("%s").Str, $function); }
			default { say "Error... no callback"; }
		}
	}

	method set_callbacks(*%callbacks) {
		for %callbacks.kv -> $name, $function {
			self.set_callback($name, $function);
		}
		return self;
	}

	###

	method set_handle(Str $name) {
		return IupSetHandle($name, self);
	}

	###

	method set_attribute_handle(Str $name, IUP::Handle $ih_named) {
		IupSetAttributeHandle(self, $name, $ih_named);
	}

	###

	method fill() {
		return IupFill();
	}

	method vboxv(*@child) {
		my $n = @child.elems;
		if $n > 1 {
			my $list = p6IupNewChildrenList($n);
			my $pos = 0;
			for @child -> $c {
				p6IupAddChildToList($list, $c, $pos, $n);
				$pos++;
			}
			my $result = IupVboxv($list);
			p6IupFree($list);
			return $result;
		}
		if $n == 1 {
			return p6IupVbox(@child[0]);
		}
	}

	method vbox(*@child) {
		return self.vboxv(@child);
	}

	method hboxv(*@child) {
		my $n = @child.elems;
		if $n > 1 {
			my $list = p6IupNewChildrenList($n);
			my $pos = 0;
			for @child -> $c {
				p6IupAddChildToList($list, $c, $pos, $n);
				$pos++;
			}
			my $result = IupHboxv($list);
			p6IupFree($list);
			return $result;
		}
		if $n == 1 {
			return p6IupHbox(@child[0]);
		}
	}

	method hbox(*@child) {
		return self.hboxv(@child);
	}

	###

	method frame($child) {
		return IupFrame($child);
	}

	###

	method image(
		Int $width where $width > 0,
		Int $height where $height > 0,
		$pixels,
		Int $color_space where 0..IUP_RGBA = 0) {

		given $color_space {
			when IUP_RGB { return IupImageRGB($width, $height, $pixels); }
			when IUP_RGBA { return IupImageRGBA($width, $height, $pixels); }
			default { return IupImage($width, $height, $pixels); }
		}
	}

	###

	method item(Str $title, Str $action) {
		return p6IupItem($title, $action);
	}

	method submenu(Str $title, $child) {
		return IupSubmenu($title, $child);
	}

	method separator() {
		return IupSeparator();
	}

	method menuv(*@child) {
		my $n = @child.elems;
		if $n > 1 {
			my $list = p6IupNewChildrenList($n);
			my $pos = 0;
			for @child -> $c {
				p6IupAddChildToList($list, $c, $pos, $n);
				$pos++;
			}
			my $result = IupMenuv($list);
			p6IupFree($list);
			return $result;
		}
		if $n == 1 {
			return p6IupMenu(@child[0]);
		}
	}

	method menu(*@child) {
		return self.menuv(@child);
	}

	###

	method button(Str $title, Str $action) {
		return p6IupButton($title, $action);
	}

	method canvas(Str $action) {
		return IupCanvas($action);
	}

	method dialog($child) {
		return IupDialog($child);
	}

	method label(Str $str) {
		return IupLabel($str);
	}

	method text(Str $action) {
		return p6IupText($action);
	}

	###

	method message(Str $title, Str $message) {
		IupMessage($title, $message);
	}
}

class IUP is IUP::Handle {

	sub p6IupOpen(int32, CArray[Str])
		returns int32 is native(LOCAL_LIB) { ... };

	sub IupClose()
		is native(LOCAL_LIB) { ... };

	sub IupImageLibOpen()
		is native(LOCAL_LIB) { ... };

	sub IupMainLoop()
		returns int32 is native(LOCAL_LIB) { ... };

	#sub IupLoopStep()
		#returns int32 is native(LOCAL_LIB) { ... };

	#sub IupLoopStepWait()
		#returns int32 is native(LOCAL_LIB) { ... };

	#sub IupMainLoopLevel()
		#returns int32 is native(LOCAL_LIB) { ... };

	#sub IupFlush()
		#is native(LOCAL_LIB) { ... };

	#sub IupExitLoop()
		#is native(LOCAL_LIB) { ... };

	###

	sub IupSetLanguage(Str)
		is native(LOCAL_LIB) { ... };

	sub IupGetLanguage()
		returns Str is native(LOCAL_LIB) { ... };

	### METHODS ###

	method open(@argv) {
		my $argc = @argv.elems;
		my $arglist := CArray[Str].new();

		my $i = 0;
		for @argv -> $a {
			$arglist[$i] = $a;
			$i++;
		}
		return p6IupOpen($argc, $arglist);
	}

	method close() {
		IupClose();
	}

	method image_lib_open() {
		IupImageLibOpen();
	}

	method main_loop() {
		return IupMainLoop();
	}

	#method loop_step(Bool $wait = False) {
		#return $wait ?? IupLoopStepWait() !! IupLoopStep();
	#}

	#method main_loop_level() {
		#return IupMainLoopLevel();
	#}

	#method flush() {
		#IupFlush();
	#}

	#method exit_loop() {
		#IupExitLoop();
	#}

	###

	method set_language($language) {
		IupSetLanguage($language);
	}

	method get_language() returns Str {
		return IupGetLanguage();
	}
}
