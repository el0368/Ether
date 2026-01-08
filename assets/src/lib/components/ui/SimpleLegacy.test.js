import { render, screen } from '@testing-library/svelte';
import { describe, it, expect } from 'vitest';
import SimpleLegacy from './SimpleLegacy.svelte';

describe('SimpleLegacy Component', () => {
    it('should behave reactively', () => {
        const { container } = render(SimpleLegacy, {
            props: { visible: true }
        });
        screen.debug();
        expect(screen.getByText('I am visible')).toBeDefined();
    });
});
