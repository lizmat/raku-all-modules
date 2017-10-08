/*
 * 
 * cc -o IUP.o -fPIC -c IUP.c
 * cc -liup -shared -s -o IUP.so IUP.o
 * rm IUP.o
 * 
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iup.h>

#ifdef WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

DLLEXPORT Ihandle **p6IupNewChildrenList(int size) {

	if(!(size > 0)) {
#ifdef DEBUG
		printf("p6IupNewChildrenList: %s\n", "Wrong size...");
#endif
		return NULL;
	}

	// n + 1 to add the NULL Terminator.
	Ihandle** children = malloc((size+1) * sizeof(Ihandle *));

#ifdef DEBUG
	printf("p6IupNewChildrenList: CHILDREN(%d) LIST(%d)\n", size, size+1);
#endif

	return children;
}

DLLEXPORT void p6IupAddChildToList(Ihandle **children, Ihandle* child, int pos, int size) {
#ifdef DEBUG
	printf("p6IupAddChildToList: POS(%d) CHILDREN(%d)\n", pos, size);
#endif

	children[pos] = child;

	if(pos+1 == size) {
#ifdef DEBUG
		printf("p6IupAddChildToList: Adds the NULL terminator at POS(%d) in the LIST(%d).\n", pos+1, size+1);
#endif
		children[pos+1] = NULL;
	}
}

DLLEXPORT void p6IupFree(void *ptr) {
#ifdef DEBUG
	printf("p6IupFree\n");
#endif
	free(ptr);
}

//
// IUP Auxiliary Functions
//

DLLEXPORT int p6IupOpen(int argc, char **argv) {
	return IupOpen(&argc, &argv);
}

DLLEXPORT Ihandle* p6IupItem(char* title, char* action) {
	return IupItem(title, strlen(action) ? action : NULL);
}

DLLEXPORT Ihandle* p6IupButton(char* title, char* action) {
	return IupButton(title, strlen(action) ? action : NULL);
}

DLLEXPORT Ihandle* p6IupMenu(Ihandle* child) {
	return IupMenu(child, NULL);
}

DLLEXPORT Ihandle* p6IupVbox(Ihandle* child) {
	return IupVbox(child, NULL);
}

DLLEXPORT Ihandle* p6IupHbox(Ihandle* child) {
	return IupHbox(child, NULL);
}

DLLEXPORT Ihandle* p6IupText(char* action) {
	return IupText(strlen(action) ? action : NULL);
}

//
// Callbacks
//

DLLEXPORT Icallback p6IupSetCallback_void(Ihandle* ih, char* name, int (*cb)(void)) {
	return IupSetCallback(ih, name, (Icallback)cb);
}

DLLEXPORT Icallback p6IupSetCallback_handle(Ihandle* ih, char* name, int (*cb)(Ihandle *)) {
	return IupSetCallback(ih, name, (Icallback)cb);
}

DLLEXPORT Icallback p6IupSetCallback_hiiiis(Ihandle* ih, char* name, int (*cb)(Ihandle *, int, int, int, int, char *)) {
	return IupSetCallback(ih, name, (Icallback)cb);
}


