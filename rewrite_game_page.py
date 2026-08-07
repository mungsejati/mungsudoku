import re

with open('lib/src/features/game/presentation/game_page.dart', 'r') as f:
    content = f.read()

# Fix mistake count
content = content.replace(
    "'Mistakes: ${state.board.mistakeCount}',",
    "'Mistakes: ${state.cumulativeMistakeCount}/${GameState.maxMistakes}',"
)

# Remove canAutoComplete
content = content.replace(
    "final canAutoComplete = ref.watch(gameNotifierProvider.select((s) => s.canAutoComplete));",
    ""
)

# Remove auto complete button usage
auto_complete_button_usage = """                    // ---- Auto Complete Button ----
                    if (canAutoComplete)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: _PulseAutoCompleteButton(),
                      ),"""
content = content.replace(auto_complete_button_usage, "")

# Add auto complete overlay
loading_overlay = """                          if (isLoading)
                            Container(
                              decoration: BoxDecoration(
                                color: gameTheme.background.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              width: 80,
                              height: 80,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),"""
overlay_replacement = """                          if (isLoading)
                            Container(
                              decoration: BoxDecoration(
                                color: gameTheme.background.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              width: 80,
                              height: 80,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          if (ref.watch(gameNotifierProvider.select((s) => s.isAutoCompleteRunning)))
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: gameTheme.background.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Auto completing...',
                                  style: TextStyle(
                                    color: gameTheme.topBarTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),"""
content = content.replace(loading_overlay, overlay_replacement)

# Remove _PulseAutoCompleteButton completely
pulse_button_class = re.search(r"class _PulseAutoCompleteButton extends ConsumerStatefulWidget \{.*", content, re.DOTALL)
if pulse_button_class:
    content = content.replace(pulse_button_class.group(0), "")

with open('lib/src/features/game/presentation/game_page.dart', 'w') as f:
    f.write(content)
