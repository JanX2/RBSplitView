//
//  main.m
//
//	RBSplitView sample app version 1.2
//  RBSplitView
//
//  Created by Rainer Brockerhoff on 01/11/2004.
//  Copyright 2004-2009 Rainer Brockerhoff.
//	Some Rights Reserved under the Creative Commons Attribution License, version 2.5, and/or the MIT License.
//

#import "main.h"

// Number of pixels to widen the lowerSplit view's divider for dragging/cursor
#define WIDEN (8)

@implementation MyAppDelegate

// This keeps firstSplit and nestedSplit the same size whenever the window is resized.
- (void)splitView:(RBSplitView*)sender wasResizedFrom:(CGFloat)oldDimension to:(CGFloat)newDimension {
	if (sender==mySplitView) {
		[sender adjustSubviewsExcepting:firstSplit];
	} else if (sender==secondSplit) {
		[sender adjustSubviewsExcepting:nestedSplit];
	}
}

// This keeps the button aligned with the left edge of the second subview, and sets its title.
- (void)splitView:(RBSplitView*)sender changedFrameOfSubview:(RBSplitSubview*)subview from:(NSRect)fromRect to:(NSRect)toRect {
	if (sender==mySplitView) {
		RBSplitSubview* firstOrSecond = [secondSplit isHidden]?thirdSplit:secondSplit;
		if (subview==firstSplit) {
// Set the button's title and state according the first subview's state.
			if ([RBSplitSubview animating]) {
				[myButton setTitle:@"="];
				[myButton setEnabled:NO];
			} else if (toRect.size.width<1.0) {
				[myButton setTitle:@">"];
				[myButton setEnabled:YES];
			} else  {
				[myButton setTitle:@"<"];
				[myButton setEnabled:YES];
			}
		} else if (subview==firstOrSecond) {
// Move the button to align with the second (or third) subview.
			NSRect oldr = [myButton frame];
			NSRect newr = oldr;
			NSView* view = [myButton superview];
			newr.origin.x = [sender convertPoint:toRect.origin toView:view].x;
			[myButton setFrame:newr];
// We ask the button's superview to redisplay just the smallest rect that covers both the old and the new position.
			[view setNeedsDisplayInRect:NSUnionRect(oldr,newr)];
		}
	}
}

// This sets the menu item titles according to the state of the first subview and second subviews.
- (BOOL)validateMenuItem:(NSMenuItem*)menuItem {
	SEL selector = [menuItem action];
	if (selector==@selector(firstAction:)) {
		switch ([firstSplit status]) {
			case RBSSubviewExpanding:
			case RBSSubviewCollapsing:
				return NO;
			case RBSSubviewNormal:
				[menuItem setTitle:@"Collapse First Split"];
				return YES;
			case RBSSubviewCollapsed:
				[menuItem setTitle:@"Expand First Split"];
				return YES;
		}
	} else if (selector==@selector(secondAction:)) {
		if ([secondSplit isHidden]) {
			[menuItem setTitle:@"Show Middle Split"];
		}  else {
			[menuItem setTitle:@"Hide Middle Split"];
		}
		return YES;
	}
	return YES;
}

// This slows the animation down to 1/5th the speed when the shift key is held down.
- (NSTimeInterval)splitView:(RBSplitView*)sender willAnimateSubview:(RBSplitSubview*)subview withDimension:(CGFloat)dimension {
// This is the default speed.
	NSTimeInterval duration = 0.2*dimension/150;
	if ([[NSApp currentEvent] modifierFlags]&NSShiftKeyMask) {
		duration *= 5.0;
	}
	return duration;
}

// This makes it possible to drag the first divider around by the dragView.
- (NSUInteger)splitView:(RBSplitView*)sender dividerForPoint:(NSPoint)point inSubview:(RBSplitSubview*)subview {
	if (subview==firstSplit) {
		if ([dragView mouse:[dragView convertPoint:point fromView:sender] inRect:[dragView bounds]]) {
			return 0;	// [firstSplit position], which we assume to be zero
		}
	// This widens the dragging region for the lowerSplit view/
	} else  if (sender==lowerSplit) {
		NSRect lead = [subview frame];
		NSRect trail = lead;
		unsigned pos = [subview position];
		BOOL ishor = [sender isHorizontal];
		CGFloat dim = DIM(trail.size);
		DIM(trail.origin) += dim-WIDEN;
		DIM(trail.size) = WIDEN;
		DIM(lead.size) = WIDEN;
		if ([sender mouse:point inRect:lead]&&(pos>0)) {
			return pos-1;
		} else if ([sender mouse:point inRect:trail]&&(pos<[sender numberOfSubviews]-1)) {
			return pos;
		}
	}
	return NSNotFound;
}

// This makes dragging any divider resize the window while the option key is held down.
// However, it doesn't work for RBSplitViews nested more than one level, so we check for that.
- (BOOL)splitView:(RBSplitView*)sender shouldResizeWindowForDivider:(NSUInteger)divider betweenView:(RBSplitSubview*)leading andView:(RBSplitSubview*)trailing willGrow:(BOOL)grow {
	return (sender!=lowerSplit)&&(([[NSApp currentEvent] modifierFlags]&NSAlternateKeyMask)!=0);
}

// This changes the cursor when it's over the dragView.
- (NSRect)splitView:(RBSplitView*)sender cursorRect:(NSRect)rect forDivider:(NSUInteger)divider {
	if ((sender==mySplitView)&&(divider==0)) {
		[sender addCursorRect:[dragView convertRect:[dragView bounds] toView:sender] cursor:[RBSplitView cursor:RBSVVerticalCursor]];
	// Also show the cursor over the widened lowerSplit view.
	} else if (sender==lowerSplit) {
		BOOL ishor = [sender isHorizontal];
		DIM(rect.origin) -= WIDEN;
		DIM(rect.size) += WIDEN*2;
	}
	return rect;
}

// This draws a white bar into the divider for the lowerSplit view.
- (NSRect)splitView:(RBSplitView*)sender willDrawDividerInRect:(NSRect)dividerRect betweenView:(RBSplitSubview*)leading andView:(RBSplitSubview*)trailing withProposedRect:(NSRect)imageRect {
	if (sender==lowerSplit) {
		[[NSColor whiteColor] set];
		NSRectFill(dividerRect);
		return NSZeroRect;
	}
	return imageRect;
}

// This collapses/expands the first subview with animation and resizing when double-clicking.
- (BOOL)splitView:(RBSplitView*)sender shouldHandleEvent:(NSEvent*)theEvent inDivider:(NSUInteger)divider betweenView:(RBSplitSubview*)leading andView:(RBSplitSubview*)trailing {
	if ((sender==mySplitView)&&(divider==0)&&([theEvent clickCount]>1)) {
		if ([leading isCollapsed]) {
			[leading expandWithAnimation:YES withResize:YES];
		} else {
			[leading collapseWithAnimation:YES withResize:YES];
		}
		return NO;
	}
	return YES;
}


// This is called for collapsing or expanding the first subview with animation but no resizing, either from the menu or from the button.
- (IBAction)firstAction:(id)sender {
	if ([firstSplit isCollapsed]) {
		[firstSplit expandWithAnimation:YES withResize:NO];
	} else {
		[firstSplit collapseWithAnimation:YES withResize:NO];
	}
}

// This is called for hiding or showing the second subview.
- (IBAction)secondAction:(id)sender {
	if ([secondSplit isHidden]) {
		[secondSplit setHidden:NO];
	} else {
		[secondSplit setHidden:YES];
	}
}

// Standard delegate method to quit when the window is closed.
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

@end

int main(int argc,char* argv[]) {
    return NSApplicationMain(argc,(const char**)argv);
}
