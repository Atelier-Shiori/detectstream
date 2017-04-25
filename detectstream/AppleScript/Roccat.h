/*
 * Roccat.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class RoccatApplication, RoccatDocument, RoccatWindow, RoccatBrowserWindow, RoccatTab;

enum RoccatSaveOptions {
	RoccatSaveOptionsYes = 'yes ' /* Save the file. */,
	RoccatSaveOptionsNo = 'no  ' /* Do not save the file. */,
	RoccatSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
};
typedef enum RoccatSaveOptions RoccatSaveOptions;

enum RoccatPrintingErrorHandling {
	RoccatPrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
	RoccatPrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum RoccatPrintingErrorHandling RoccatPrintingErrorHandling;

enum RoccatCaptureOptions {
	RoccatCaptureOptionsScreenshot = 'Scrn' /* Capture the web page as a screenshot. */,
	RoccatCaptureOptionsWebArchive = 'WbAr' /* Capture the web page as a Web Archive document. */,
	RoccatCaptureOptionsRawSource = 'Src ' /* Capture the web page as a raw source. */
};
typedef enum RoccatCaptureOptions RoccatCaptureOptions;

@protocol RoccatGenericMethods

- (void) closeSaving:(RoccatSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) runWorkflowWithVariables:(NSDictionary *)withVariables;  // Run this document's workflow.
- (void) waitUntilDoneWithTimeout:(double)withTimeout;  // Wait until this document is done running a workflow. If a workflow is not running, returns immediately.
- (void) stopWorkflow;  // Stop this document's workflow.
- (void) goBack;  // Go back.
- (void) goForward;  // Go forward.
- (void) goHome;  // Go home.
- (void) goHome;  // dark tab.
- (void) reload;  // Reload a web page.
- (void) stopLoading;  // Stop loading a web page.
- (void) zoomIn;  // Zoom in contents of the page.
- (void) zoomOut;  // Zoom out contents of the page.
- (void) showActualSize;  // Zoom contents of the page to actual size.

@end



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface RoccatApplication : SBApplication
+ (RoccatApplication *) application;

- (SBElementArray<RoccatDocument *> *) documents;
- (SBElementArray<RoccatBrowserWindow *> *) browserWindows;
- (SBElementArray<RoccatWindow *> *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (id) open:(id)x;  // Open a document.
- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quitSaving:(RoccatSaveOptions)saving;  // Quit the application.
- (BOOL) exists:(id)x;  // Verify that an object exists.
- (void) loadURL:(NSString *)x in:(RoccatTab *)in_;  // Load a URL.
- (id) doJavaScript:(NSString *)x in:(RoccatTab *)in_;  // Applies a string of JavaScript code to a document.
- (void) dismissJavaScriptDialogWithButton:(NSString *)withButton in:(RoccatTab *)in_;  // Dismisses a JavaScript alert() dialog by clicking a button.
- (void) clickLinkWithId:(NSString *)withId withName:(NSString *)withName withText:(NSString *)withText forXPath:(NSString *)forXPath forCSSSelector:(NSString *)forCSSSelector in:(RoccatTab *)in_;  // Activates a hyperlink in this tab's web page.
- (void) clickButtonWithId:(NSString *)withId withName:(NSString *)withName withText:(NSString *)withText forXPath:(NSString *)forXPath forCSSSelector:(NSString *)forCSSSelector in:(RoccatTab *)in_;  // Activates a button in this tab's web page.
- (void) setValueOfElementWithName:(NSString *)withName withId:(NSString *)withId inFormWithName:(NSString *)inFormWithName inFormWithId:(NSString *)inFormWithId inFormForXPath:(NSString *)inFormForXPath inFormForCSSSelector:(NSString *)inFormForCSSSelector forXPath:(NSString *)forXPath forCSSSelector:(NSString *)forCSSSelector to:(NSString *)to in:(RoccatTab *)in_;  // Sets the value of an HTML input element in this tab's web page.
- (void) focusElementWithName:(NSString *)withName withId:(NSString *)withId inFormWithName:(NSString *)inFormWithName inFormWithId:(NSString *)inFormWithId inFormForXPath:(NSString *)inFormForXPath inFormForCSSSelector:(NSString *)inFormForCSSSelector forXPath:(NSString *)forXPath forCSSSelector:(NSString *)forCSSSelector to:(NSString *)to in:(RoccatTab *)in_;  // Gives focus to an HTML input element in this tab's web page.
- (void) submitFormWithName:(NSString *)withName withId:(NSString *)withId forXPath:(NSString *)forXPath forCSSSelector:(NSString *)forCSSSelector in:(RoccatTab *)in_;  // Submits an HTML form in this tab's web page.
- (void) setFormValuesWithName:(NSString *)withName withId:(NSString *)withId forXPath:(NSString *)forXPath forCSSSelector:(NSString *)forCSSSelector withValues:(NSDictionary *)withValues in:(RoccatTab *)in_;  // Sets multiple values in the specified HTML form in this tab's web page.
- (void) assertPageTitleEquals:(NSString *)pageTitleEquals HTTPStatusCodeEquals:(NSString *)HTTPStatusCodeEquals HTTPStatusCodeIsNotEqual:(NSString *)HTTPStatusCodeIsNotEqual pageHasElementWithId:(NSString *)pageHasElementWithId pageDoesNotHaveElementWithId:(NSString *)pageDoesNotHaveElementWithId pageHasElementForXPath:(NSString *)pageHasElementForXPath pageDoesNotHaveElementForXPath:(NSString *)pageDoesNotHaveElementForXPath pageContainsText:(NSString *)pageContainsText pageDoesNotContainText:(NSString *)pageDoesNotContainText JavaScriptEvaluatesTrue:(NSString *)JavaScriptEvaluatesTrue XPathEvaluatesTrue:(NSString *)XPathEvaluatesTrue in:(RoccatTab *)in_;  // Asserts a condition in this tab's web page is true. Throws an AppleScript error if false.
- (void) waitForConditionPageTitleEquals:(NSString *)pageTitleEquals pageHasElementWithId:(NSString *)pageHasElementWithId pageDoesNotHaveElementWithId:(NSString *)pageDoesNotHaveElementWithId pageHasElementForXPath:(NSString *)pageHasElementForXPath pageDoesNotHaveElementForXPath:(NSString *)pageDoesNotHaveElementForXPath pageContainsText:(NSString *)pageContainsText pageDoesNotContainText:(NSString *)pageDoesNotContainText JavaScriptEvaluatesTrue:(NSString *)JavaScriptEvaluatesTrue XPathEvaluatesTrue:(NSString *)XPathEvaluatesTrue withTimeout:(double)withTimeout in:(RoccatTab *)in_;  // Waits for a condition in this tab's web page to become true. Throws an AppleScript error if false after specified timeout.
- (void) dispatchMouseEventWithType:(NSString *)withType toElementWithId:(NSString *)toElementWithId toElementWithName:(NSString *)toElementWithName toElementForXPath:(NSString *)toElementForXPath toElementForCSSSelector:(NSString *)toElementForCSSSelector relatedTargetWithId:(NSString *)relatedTargetWithId relatedTargetWithName:(NSString *)relatedTargetWithName relatedTargetForXPath:(NSString *)relatedTargetForXPath relatedTargetForCSSSelector:(NSString *)relatedTargetForCSSSelector clickCount:(NSInteger)clickCount button:(NSInteger)button controlKeyPressed:(BOOL)controlKeyPressed optionKeyPressed:(BOOL)optionKeyPressed shiftKeyPressed:(BOOL)shiftKeyPressed commandKeyPressed:(BOOL)commandKeyPressed in:(RoccatTab *)in_;  // Dispatches a mouse event to a given element in this tab's web page.
- (void) dispatchKeyboardEventWithType:(NSString *)withType toElementWithId:(NSString *)toElementWithId toElementWithName:(NSString *)toElementWithName toElementForXPath:(NSString *)toElementForXPath toElementForCSSSelector:(NSString *)toElementForCSSSelector keyCode:(NSInteger)keyCode charCode:(NSInteger)charCode controlKeyPressed:(BOOL)controlKeyPressed optionKeyPressed:(BOOL)optionKeyPressed shiftKeyPressed:(BOOL)shiftKeyPressed commandKeyPressed:(BOOL)commandKeyPressed in:(RoccatTab *)in_;  // Dispatches a keyboard event to a given element in this tab's web page.
- (void) captureWebPageAs:(RoccatCaptureOptions)as savingIn:(NSURL *)savingIn in:(RoccatTab *)in_;  // Capture this tab's web page as a screenshot, Web Archive or raw source.
- (void) setVariableWithName:(NSString *)withName toLiteralValue:(NSString *)toLiteralValue toValueOfXPath:(NSString *)toValueOfXPath toValueOfElementWithId:(NSString *)toValueOfElementWithId toValueOfElementWithName:(NSString *)toValueOfElementWithName toValueOfElementForXPath:(NSString *)toValueOfElementForXPath toValueOfElementForCSSSelector:(NSString *)toValueOfElementForCSSSelector in:(RoccatTab *)in_;  // Set the value of a Fake variable.
- (void) goBack;  // Go back.
- (void) goForward;  // Go forward.
- (void) goHome;  // Go home.
- (void) goHome;  // dark tab.
- (void) reload;  // Reload a web page.
- (void) stopLoading;  // Stop loading a web page.
- (void) zoomIn;  // Zoom in contents of the page.
- (void) zoomOut;  // Zoom out contents of the page.
- (void) showActualSize;  // Zoom contents of the page to actual size.

@end

// A document.
@interface RoccatDocument : SBObject <RoccatGenericMethods>

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.


@end

// A window.
@interface RoccatWindow : SBObject <RoccatGenericMethods>

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
@property (copy, readonly) RoccatDocument *document;  // The document whose contents are displayed in the window.


@end



/*
 * Fluidium Suite
 */

// A browser window.
@interface RoccatBrowserWindow : RoccatDocument

- (SBElementArray<RoccatTab *> *) tabs;

@property (copy, readonly) NSString *title;  // The current title of the web page currently loaded in this window (same as the title of the selected tab in this window).
@property (copy, readonly) NSString *URL;  // The URL of the web page currently loaded in this tab (same as the URL of the selected tab in this window).
@property (readonly) BOOL loading;  // True if this window's web page is currently loading. Otherwise false. (same as the loading property of the selected tab in this window).
@property (copy, readonly) NSString *source;  // The HTML source of the web page currently loaded in this window (same as the source of the selected tab in this window).
@property (copy) RoccatTab *selectedTab;  // The selected tab in this window.


@end

// A browser tab.
@interface RoccatTab : SBObject <RoccatGenericMethods>

@property (readonly) NSInteger index;  // The index of this tab in its window.
@property (copy, readonly) NSString *title;  // The title of the web page currently loaded in this tab.
@property (copy, readonly) NSString *URL;  // The URL of the web page currently loaded in this tab.
@property (readonly) BOOL loading;  // True if this tab's web page is currently loading. Otherwise false.
@property (readonly) BOOL selected;  // True if this is the selected tab in its window. Otherwise false.
@property (copy, readonly) NSString *source;  // The HTML source of the web page currently loaded in this tab.


@end

