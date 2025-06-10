# Visual Testing with Playwright

Use Playwright to visually test your recent UI changes:

## Testing Tasks

1. **Identify what to test**
   - List all UI components you've modified
   - Note any new user flows or interactions
   - Consider responsive design breakpoints

2. **Run visual tests**
   - Use Playwright's screenshot capabilities
   - Test in multiple browsers (Chromium, Firefox, WebKit)
   - Capture different states (loading, error, success)
   - Test both light and dark modes if applicable

3. **Interaction testing**
   - Click through user workflows
   - Test form submissions
   - Verify animations and transitions
   - Check hover states and focus indicators

4. **Accessibility checks**
   - Verify keyboard navigation works
   - Test with screen reader announcements
   - Check color contrast ratios
   - Ensure proper ARIA labels

5. **Cross-browser validation**
   - Compare rendering across browsers
   - Test on different viewport sizes
   - Verify consistent behavior

## Commands to use

```bash
# Run specific visual tests
npm run test:visual

# Run with UI mode for debugging
npm run test:playwright:ui

# Run in headed mode to watch tests
npm run test:playwright:headed

# Generate new baseline screenshots
npx playwright test --update-snapshots
```

## What to look for

- Layout shifts or broken designs
- Missing styles or incorrect colors
- Overlapping elements
- Text that's cut off or wrapped incorrectly
- Interactive elements that don't respond
- Loading states that get stuck
- Error messages that don't display properly

Remember to commit any new or updated snapshot files if the visual changes are intentional!