# Setup Guide: macOS Pointer Control for Vision Command 2026

This guide walks you through enabling and configuring macOS Pointer Control so you can play Vision Command 2026 using eye tracking and face gestures.

---

## Prerequisites

- macOS Sonoma (14.0) or newer
- A Mac with a built-in FaceTime HD camera or TrueDepth camera
- Good lighting conditions (avoid backlighting or very dim rooms)
- A comfortable seated position where you can see the screen clearly

---

## Step 1: Enable Pointer Control

1. Open **System Settings** (Apple menu → System Settings)
2. Navigate to **Accessibility** in the left sidebar
3. Scroll down and click **Pointer Control**
4. Find the **Alternate Control Methods** section
5. Toggle on **Eye Tracking** or **Head Pointer** (or both)

> **Note:** Eye Tracking requires a TrueDepth camera (available on newer MacBook Pro and iMac models). Head Pointer works with any FaceTime HD camera.

---

## Step 2: Complete Calibration

### Eye Tracking Calibration

1. After enabling Eye Tracking, click **Calibrate Eye Tracking**
2. Follow the on-screen instructions:
   - Position yourself comfortably in front of the screen
   - Keep your head relatively still
   - Look at each calibration target as it appears
   - The system will track several points across the screen
3. Complete the calibration sequence (usually 9-16 points)
4. Test the pointer movement by looking around the screen

**Tips for better calibration:**
- Sit 18-24 inches from the screen
- Ensure your face is well-lit and clearly visible to the camera
- Remove glasses if they cause glare (though many users can calibrate with glasses on)
- If calibration fails, try adjusting your lighting and distance

### Head Pointer Calibration

1. After enabling Head Pointer, click **Calibrate Head Pointer**
2. The system will track your head movements
3. Move your head slowly in different directions to control the pointer
4. Adjust sensitivity settings if needed

---

## Step 3: Configure Dwell Control (Recommended for Beginners)

Dwell control allows you to "click" by holding your gaze on a spot for a set duration.

1. In **Pointer Control** settings, find **Dwell Control**
2. Toggle **Dwell Control** on
3. Adjust settings:
   - **Dwell time:** Start with 0.6-0.7 seconds (600-700ms)
   - **Movement tolerance:** Medium (prevents accidental triggers)
4. Enable **Show dwell ring** to see visual feedback while dwelling

**For Vision Command 2026:**
- The game works best with dwell times between 500-700ms
- Too short = accidental fires
- Too long = frustrating gameplay

---

## Step 4: Configure Face Gestures (Optional)

Face gestures provide alternative ways to trigger clicks without dwelling.

1. In **Pointer Control** settings, scroll to **Face Gestures**
2. Toggle **Face Gestures** on
3. Click **Customize Gestures**
4. Assign actions to gestures:

**Recommended for Vision Command 2026:**
- **Left Eye Blink** or **Right Eye Blink** → Primary Click
- **Raise Eyebrows** → Primary Click (alternative to blink)
- **Open Mouth** → Primary Click (less tiring for some users)

5. Practice each gesture to ensure reliable detection
6. Adjust sensitivity if gestures trigger too easily or not at all

**Tips:**
- Start with one gesture type and add more as you get comfortable
- Blinks work well but can cause fatigue during extended play
- Eyebrow raises are often less tiring for longer sessions

---

## Step 5: Adjust Pointer Settings

Fine-tune how the pointer responds to your gaze or head movement:

1. In **Pointer Control**, find **Tracking speed**
2. Start with a medium speed setting
3. Adjust based on comfort:
   - **Slower:** More precise but requires more head/eye movement
   - **Faster:** Easier to reach corners but less precise
4. Enable **Smooth pointer movement** to reduce jitter

**For Vision Command 2026:**
- Medium to medium-fast tracking works best
- The game has large target areas, so precision isn't critical
- Smoothing helps with steady aiming

---

## Step 6: Test Your Setup

Before launching the game:

1. Open a web browser or text editor
2. Practice moving the pointer around the screen with your eyes/head
3. Test your click method (dwell or gesture)
4. Try selecting different areas of the screen
5. Verify that clicks register reliably

**Common issues:**
- **Pointer jumps around:** Recalibrate or adjust tracking speed
- **Dwell triggers too often:** Increase dwell time or movement tolerance
- **Gestures don't register:** Adjust lighting or gesture sensitivity
- **Eye strain:** Take breaks, adjust screen brightness, increase dwell time

---

## Step 7: Launch Vision Command 2026

1. Open the game
2. Start with the default dwell-to-fire control
3. Play a short session (1-2 minutes) to test responsiveness
4. Adjust settings in macOS Pointer Control if needed
5. Experiment with face gestures once comfortable with dwell

---

## Troubleshooting

### Pointer is jittery or unstable
- Recalibrate eye tracking
- Enable smooth pointer movement
- Improve lighting conditions
- Ensure camera lens is clean
- Reduce screen brightness if causing eye strain

### Dwell doesn't trigger consistently
- Increase movement tolerance
- Slow down your eye movements when targeting
- Ensure dwell ring is visible (helps with timing)
- Check that dwell time isn't too long

### Face gestures trigger accidentally
- Reduce gesture sensitivity
- Choose different gestures (some are more prone to false triggers)
- Practice the gesture deliberately and consistently

### Camera doesn't detect face/eyes
- Check camera permissions (System Settings → Privacy & Security → Camera)
- Improve lighting (face your light source, avoid backlight)
- Move closer or farther from screen (18-24 inches is ideal)
- Remove or adjust glasses if causing issues

### Eye strain or fatigue
- Take breaks every 5-10 minutes
- Reduce screen brightness
- Use dwell instead of blink gestures
- Increase dwell time to reduce focus intensity
- Adjust room lighting to reduce glare

---

## Accessibility Resources

- **Apple Support:** [Use Eye Tracking on Mac](https://support.apple.com/guide/mac-help/use-eye-tracking-mchl06d90aef/mac)
- **Apple Support:** [Use Head Pointer on Mac](https://support.apple.com/guide/mac-help/use-head-pointer-mchl77e0b3ba/mac)
- **Feedback:** If you encounter issues specific to Vision Command 2026, please open an issue on GitHub

---

## Optimal Play Environment

For the best experience:

- **Lighting:** Bright, even lighting from in front or above (not behind)
- **Distance:** 18-24 inches from screen
- **Posture:** Comfortable seated position with screen at eye level
- **Session length:** 5-10 minute sessions with breaks
- **Screen:** Matte screens work better than glossy (less glare)

---

## Next Steps

Once you have Pointer Control configured:
1. Review `/docs/accessibility-notes.md` for game-specific settings
2. Check `/docs/design-notes.md` to understand gameplay tuning
3. Start playing and adjust macOS settings as needed
4. Share feedback on what control schemes work best for you

---

**Ready to defend your cities? Launch Vision Command 2026 and start playing!**
