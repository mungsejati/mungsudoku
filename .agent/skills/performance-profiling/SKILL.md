---
name: performance-profiling
description: Performance profiling principles. Measurement, analysis, and optimization techniques.
allowed-tools: Read, Glob, Grep, Bash
---

# Performance Profiling

> Measure, analyze, optimize - in that order.

## 🔧 Runtime Scripts

**Execute these for automated profiling:**

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/analyze_size.sh` | Analyze app bundle size | `flutter build apk --analyze-size` |

---

## 1. Flutter Performance Vitals

## 1.5. Flutter Performance Vitals

### Targets
| Metric | Good | Poor | Context |
|--------|------|------|---------|
| **UI Thread** | < 16ms | > 16ms | Dartmouth execution & Widget building |
| **Raster Thread** | < 16ms | > 16ms | GPS/Skia rendering commands |
| **FPS** | 60/120 | < 55 | Smoothness |
| **Jank** | 0 frames | > 0 | Dropped frames |

### When to Measure
| Stage | Tool |
|-------|------|
| Development | DevTools (Performance View) |
| Profiling | **Profile Mode** (`flutter run --profile`) |
| Production | Firebase Performance Monitoring |

---

## 2. Profiling Workflow

### The 4-Step Process

```
1. BASELINE → Measure current state
2. IDENTIFY → Find the bottleneck
3. FIX → Make targeted change
4. VALIDATE → Confirm improvement
```

### Profiling Tool Selection

| Problem | Tool |
|---------|------|
| App Size | `flutter build --analyze-size` |
| UI Jank | DevTools Performance |
| CPU usage | DevTools CPU Profiler |
| Memory leaks | DevTools Memory |
| Network lag | DevTools Network |

---

## 2.5. Flutter Profiling Workflow

### The Golden Rule
> 🔴 **NEVER profile in DEBUG mode.** Performance metrics are meaningless in debug mode (JIT enabled, assertions on).
> ✅ **ALWAYS use PROFILE mode:** `flutter run --profile`

### DevTools Workflow
1. **Performance View**: Enable "Track Widget Builds". Look for flame chart spikes.
2. **CPU Profiler**: Identify expensive Dart methods (deep stacks).
3. **Memory View**: Detect leaks (Snapshot diffs).

---

## 3. Flutter Build Analysis

### What to Look For

| Issue | Indicator |
|-------|-----------|
| Large Assets | Top of size report |
| Unused Packages | Found in `pubspec.yaml` |
| Large Dependencies | `flutter pub run dart_code_metrics:metrics` |
| Native Bloat | `build/app/outputs/size-report.json` |

### Optimization Actions

| Finding | Action |
|---------|--------|
| Large images | Compress or use WebP |
| Heavy package | Find lighter alternative |
| Debug code in release | Use `kReleaseMode` |
| Duplicate code | Refactor into common widgets |

---


## 5. Common Bottlenecks

### By Symptom

| Symptom | Likely Cause |
|---------|--------------|
| High Frame Time | Heavy build method |
| High Raster Time | Expensive graphics (Shadows/Clips) |
| App Size Bloat | Unoptimized assets |
| Growing memory | Leaks (leaked listeners) |

---

## 5.5. Flutter Specific Bottlenecks

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| **Jank on first run** | Shader Compilation | Impeller (Standard on iOS/Android now) |
| **Jank on scroll** | Expensive `build()` | `const` widgets, extract widgets |
| **High CPU** | Layout Thrashing | Avoid `IntrinsicHeight`, `ShrinkWrap` |
| **Image stutter** | Main thread decoding | Cache images, resize in worker |
| **Memory Spike** | Large images | `cacheWidth`/`cacheHeight` in `NetworkImage` |

---

## 6. Quick Win Priorities

| Priority | Action | Impact |
|----------|--------|--------|
| 1 | Enable Impeller | High |
| 2 | Use `const` widgets | High |
| 3 | Optimize Images | Medium |
| 4 | Shrink Unused Assets | Medium |
| 5 | Lazy build Lists | Medium |

---

## 7. Anti-Patterns

| ❌ Don't | ✅ Do |
|----------|-------|
| Guess at problems | Profile first |
| Micro-optimize | Fix biggest issue |
| Optimize early | Optimize when needed |
| Ignore real users | Use RUM data |

---

> **Remember:** The fastest code is code that doesn't run. Remove before optimizing.
