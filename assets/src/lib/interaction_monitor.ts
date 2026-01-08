/**
 * Interaction Monitor for Ether IDE
 * Measures precise E2E latency from 'Action' to 'Next Paint'
 */

class InteractionMonitor {
    private marks: Map<string, number> = new Map();

    constructor() {
        console.log("🚀 InteractionMonitor initialized");
    }

    /**
     * Start measuring a specific interaction
     */
    public start(interactionId: string) {
        this.marks.set(interactionId, performance.now());
    }

    /**
     * Stop measuring and return the latency in milliseconds
     * Uses requestAnimationFrame to ensure we measure until the browser actually paints the update.
     */
    public stop(interactionId: string, metricName: string = 'e2e_latency') {
        const startTime = this.marks.get(interactionId);
        if (!startTime) return;

        requestAnimationFrame(() => {
            // requestAnimationFrame runs before the paint.
            // We want to measure AFTER the paint, so we use a second RAF or a setTimeout(0)
            requestAnimationFrame(() => {
                const endTime = performance.now();
                const latency = endTime - startTime;
                this.report(metricName, latency, interactionId);
                this.marks.delete(interactionId);
            });
        });
    }

    private report(metric: string, value: number, id: string) {
        const status = value < 16 ? 'PREMIUM' : value < 50 ? 'GOOD' : 'LAGGY';
        const color = status === 'PREMIUM' ? 'color: #00ff00' : status === 'GOOD' ? 'color: #ffff00' : 'color: #ff0000';
        
        console.log(`%c📊 [${metric}] ${id}: ${value.toFixed(2)}ms (${status})`, color);

        // Store for dashboard
        localStorage.setItem(`last_${metric}`, value.toString());
        
        // Push to backend if socket is available
        if ((window as any).editorChannel) {
            (window as any).editorChannel.push("benchmark:report", {
                metric: metric,
                latency: value,
                id: id
            });
        }
    }
}

const monitor = new InteractionMonitor();
export default monitor;
export const startInteraction = (id: string) => monitor.start(id);
export const stopInteraction = (id: string, metric?: string) => monitor.stop(id, metric);
