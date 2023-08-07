/*
 * Orion.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class OrionApplication, OrionDocument, OrionWindow, OrionTab;

enum OrionSaveOptions {
    OrionSaveOptionsYes = 'yes ' /* Save the file. */,
    OrionSaveOptionsNo = 'no  ' /* Do not save the file. */,
    OrionSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
};
typedef enum OrionSaveOptions OrionSaveOptions;

enum OrionPrintingErrorHandling {
    OrionPrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
    OrionPrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum OrionPrintingErrorHandling OrionPrintingErrorHandling;

@protocol OrionGenericMethods

- (void) closeSaving:(OrionSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(id)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface OrionApplication : SBApplication

- (SBElementArray<OrionDocument *> *) documents;
- (SBElementArray<OrionWindow *> *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (id) open:(id)x;  // Open a document.
- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quitSaving:(OrionSaveOptions)saving;  // Quit the application.
- (BOOL) exists:(id)x;  // Verify that an object exists.
- (id) doJavaScript:(NSString *)x in:(id)in_;  // Applies a string of JavaScript code to a document.

@end

// A document.
@interface OrionDocument : SBObject <OrionGenericMethods>

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.


@end

// A window.
@interface OrionWindow : SBObject <OrionGenericMethods>

@property (copy, readonly) NSString *name;  // The title of the window.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Does the window have a close button?
@property (readonly) BOOL miniaturizable;  // Does the window have a minimize button?
@property BOOL miniaturized;  // Is the window minimized right now?
@property (readonly) BOOL resizable;  // Can the window be resized?
@property BOOL visible;  // Is the window visible right now?
@property (readonly) BOOL zoomable;  // Does the window have a zoom button?
@property BOOL zoomed;  // Is the window zoomed right now?
@property (copy, readonly) OrionDocument *document;  // The document whose contents are displayed in the window.


@end



/*
 * Orion Suite
 */

// A Orion window.
@interface OrionWindow (OrionSuite)

- (SBElementArray<OrionTab *> *) tabs;

@property (copy) OrionTab *currentTab;  // The current tab.

@end

// A Orion document representing the active tab in a window.
@interface OrionDocument (OrionSuite)

@property (copy) NSString *URL;  // The current URL of the document.

@end

// A Orion window tab.
@interface OrionTab : SBObject <OrionGenericMethods>

@property (copy) NSString *URL;  // The current URL of the tab.
@property (copy, readonly) NSString *name;  // The name of the tab.


@end

