import { describe, it, expect } from 'vitest';

describe('Sanity Check', () => {
    it('should pass basic assertions', () => {
        expect(true).toBe(true);
    });

    it('should have access to document', () => {
        expect(document).toBeDefined();
    });
});
