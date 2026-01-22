# Naitre HUD
## Wayland Compositor and Window Manager
![MangoWC Logo](https://raw.githubusercontent.com/nixpup/NaitreHUD/refs/heads/main/naitre_logo.png)

# Preface
This is a fork of the [MangoWC](https://github.com/DreamMaoMao/mangowc) Wayland Compositor and Window Manager with a few added features and changes made that I found to be useful or necessary. All credit goes to the creator of [MangoWC](https://github.com/DreamMaoMao/mangowc) [DreamMaoMao](https://github.com/DreamMaoMao).

# New Features
## Vertical Stacking
This build of MangoWC supports *vertical stacking* within the *scroller* layout, similar to how the Niri Wayland Compositor and Window Manager works. This means by binding the following actions in your `~/.config/mango/config.conf`:
```
bind=Alt,comma,scroller_stack_left
bind=Alt,period,scroller_stack_right
```
You can automatically split/resize the window to the left (or right) of the currently selected window, and then move/tile the currently selected window below the window to its left (or right) via the `scroller_stack_left` (or `*_right`) option. Removing a window from a stack is triggered by invoking the action to stack in the opposite direction.

### Action Breakdown
1. `scroller_stack_left` - Enter new stack (or exit existing stack) with existing window to the left.
2. `scroller_stack_right` - Enter new stack (or exit existing stack) with existing window to the right.

## Infinite Layout
Similar to what the [hevel](https://git.sr.ht/~dlm/hevel/) Wayland Window Manager does, the Naitre HUD includes a layout called *"infinite"*, which allows the user to place windows anywhere on a virtually infinite desktop, and navigate the layout/move the view easily via keybinds.

To use the layout simple choose a workspace to turn into an *"infinite"* workspace, like so:
```
tagrule=id:3,layout_name:infinite
```

And then configure the necessary keybinds:
```
bind=Alt,Tab,infinite_move_start
bindr=Alt,Tab,infinite_move_end
bind=Alt+Shift,c,infinite_center
```

The new keybind configuration option `bindr` can check for the release of a key, allowing you to, like in this example, **hold down** the `Alt+Tab` key combination to move the users view of the infinite desktop with their mouse, and stop moving on release of the keybind.

### Action Breakdown
1. `infinite_move_start` - On key press, enter view movement mode.
2. `infinite_move_end` - (When used with `bindr` ...) on key release, exit the view movement mode.
3. `infinite_center` - Move and center the users desktop view on the currently selected window.

## Stacker Looping
In your `~/.config/mango/config.conf`, there is now a new option called `stacker_loop` that can be set to either `1` (true/enable) or `0` (false/disable), which looks like this:
```
stacker_loop=1
```
This option, when enabled, allows you to, when invoking either `scroller_stack_left` with no window left of the currently selected one or vice versa for `scroller_stack_right`, to loop around all windows to the other end and create a stack there.

So invoking `scoller_stack_left` on the selected leftmost window on your desktop, while `stacker_loop=1` is in your config, will move the window all the way to the right of all present windows, and create a new stack with the last window present all the way to the right.

# Demonstrations
## Vertical Stacking
[![Demo Video](https://raw.githubusercontent.com/nixpup/NaitreHUD/refs/heads/main/verticalStackingThumbnail.png)](https://github.com/nixpup/NaitreHUD/blob/main/verticalStackingDemo.mp4)
**Click the Thumbnail to Download or View the Demo Video**

## Infinite Layout
[![Demo Video](https://raw.githubusercontent.com/nixpup/NaitreHUD/refs/heads/main/infiniteLayoutThumbnail.png)](https://github.com/nixpup/NaitreHUD/blob/main/infiniteLayoutDemo.mp4)
**Click the Thumbnail to Download or View the Demo Video**
