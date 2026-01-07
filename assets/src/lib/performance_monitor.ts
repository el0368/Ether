/**
 * Performance Monitor for Ether IDE
 * Tracks Core Web Vitals and reports to backend
 */

interface PerformanceMetrics {
  lcp: number | null;
  fid: number | null;
  cls: number | null;
  ttfb: number | null;
  fcp: number | null;
}

class PerformanceMonitor {
  private metrics: PerformanceMetrics = {
    lcp: null,
    fid: null,
    cls: null,
    ttfb: null,
    fcp: null
  };

  constructor() {
    this.observeLCP();
    this.observeFID();
    this.observeCLS();
    this.measureNavigationTiming();
  }

  /**
   * Largest Contentful Paint (LCP)
   * Target: <2.5s (good), <4.0s (needs improvement)
   */
  private observeLCP() {
    if (!('PerformanceObserver' in window)) return;

    const observer = new PerformanceObserver((list) => {
      const entries = list.getEntries();
      const lastEntry = entries[entries.length - 1] as any;
      this.metrics.lcp = lastEntry.renderTime || lastEntry.loadTime;
      this.report('lcp', this.metrics.lcp);
    });

    observer.observe({ type: 'largest-contentful-paint', buffered: true });
  }

  /**
   * First Input Delay (FID)
   * Target: <100ms (good), <300ms (needs improvement)
   */
  private observeFID() {
    if (!('PerformanceObserver' in window)) return;

    const observer = new PerformanceObserver((list) => {
      const entries = list.getEntries();
      entries.forEach((entry: any) => {
        this.metrics.fid = entry.processingStart - entry.startTime;
        this.report('fid', this.metrics.fid);
      });
    });

    observer.observe({ type: 'first-input', buffered: true });
  }

  /**
   * Cumulative Layout Shift (CLS)
   * Target: <0.1 (good), <0.25 (needs improvement)
   */
  private observeCLS() {
    if (!('PerformanceObserver' in window)) return;

    let clsValue = 0;
    const observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries() as any[]) {
        if (!entry.hadRecentInput) {
          clsValue += entry.value;
          this.metrics.cls = clsValue;
        }
      }
      this.report('cls', this.metrics.cls);
    });

    observer.observe({ type: 'layout-shift', buffered: true });
  }

  /**
   * Navigation Timing (TTFB, FCP)
   */
  private measureNavigationTiming() {
    if (!('performance' in window)) return;

    window.addEventListener('load', () => {
      const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
      
      if (navigation) {
        // Time to First Byte
        this.metrics.ttfb = navigation.responseStart - navigation.requestStart;
        this.report('ttfb', this.metrics.ttfb);
      }

      // First Contentful Paint
      const paintEntries = performance.getEntriesByType('paint');
      const fcpEntry = paintEntries.find(entry => entry.name === 'first-contentful-paint');
      
      if (fcpEntry) {
        this.metrics.fcp = fcpEntry.startTime;
        this.report('fcp', this.metrics.fcp);
      }
    });
  }

  /**
   * Report metric to console and optionally to backend
   */
  private report(metric: string, value: number | null) {
    if (value === null) return;

    const status = this.getStatus(metric, value);
    const emoji = status === 'good' ? '✅' : status === 'needs-improvement' ? '⚠️' : '❌';
    
    console.log(`${emoji} ${metric.toUpperCase()}: ${value.toFixed(2)}ms (${status})`);

    // Store in localStorage for dashboard
    const key = `perf_${metric}`;
    localStorage.setItem(key, value.toString());

    // TODO: Send to backend via Phoenix channel
    // this.sendToBackend(metric, value);
  }

  /**
   * Get performance status based on Core Web Vitals thresholds
   */
  private getStatus(metric: string, value: number): 'good' | 'needs-improvement' | 'poor' {
    const thresholds: Record<string, [number, number]> = {
      lcp: [2500, 4000],
      fid: [100, 300],
      cls: [0.1, 0.25],
      ttfb: [800, 1800],
      fcp: [1800, 3000]
    };

    const [good, needsImprovement] = thresholds[metric] || [0, 0];

    if (value <= good) return 'good';
    if (value <= needsImprovement) return 'needs-improvement';
    return 'poor';
  }

  /**
   * Get all metrics
   */
  public getMetrics(): PerformanceMetrics {
    return { ...this.metrics };
  }

  /**
   * Send metrics to backend (optional)
   */
  private sendToBackend(metric: string, value: number) {
    // TODO: Implement Phoenix channel communication
    // window.channel?.push('performance:metric', { metric, value });
  }
}

// Auto-initialize if in browser
if (typeof window !== 'undefined') {
  const monitor = new PerformanceMonitor();
  
  // Expose to window for debugging
  (window as any).performanceMonitor = monitor;
  
  // Log summary after 5 seconds
  setTimeout(() => {
    const metrics = monitor.getMetrics();
    console.log('📊 Performance Summary:', metrics);
  }, 5000);
}

export default PerformanceMonitor;
