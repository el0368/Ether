/**
 * NifDecoder - Zero-Copy Binary Protocol Parser
 * Decodes the [Type:u8][Len:u16][Path:Bytes] format from Aether.Native
 */

export interface FileEntry {
    name: string;
    type: 'file' | 'directory' | 'symlink' | 'other';
    path: string; // Absolute path reconstruction
}

export class NifDecoder {
    private static decoder = new TextDecoder('utf-8');

    static decode(buffer: Uint8Array, root: string): FileEntry[] {
        const entries: FileEntry[] = [];
        let offset = 0;

        // Safety check
        if (!buffer || buffer.byteLength === 0) return [];

        const view = new DataView(buffer.buffer, buffer.byteOffset, buffer.byteLength);

        while (offset < buffer.byteLength) {
            if (offset + 3 > buffer.byteLength) break; // Incomplete header

            // 1. Type (1 byte)
            const typeCode = view.getUint8(offset);
            offset += 1;

            // 2. Length (2 bytes, LE)
            const len = view.getUint16(offset, true); // true = Little Endian
            offset += 2;

            if (offset + len > buffer.byteLength) break; // Incomplete body

            // 3. Name (Bytes)
            // Optimized for small strings
            const nameBytes = buffer.subarray(offset, offset + len);
            const name = this.decoder.decode(nameBytes);
            offset += len;

            entries.push({
                name: name,
                type: this.mapType(typeCode),
                path: `${root}/${name}` // Naive join, server should handle path separators if needed or frontend normalizes
            });
        }

        return entries.sort((a, b) => {
            // Sort directories first
            if (a.type === 'directory' && b.type !== 'directory') return -1;
            if (a.type !== 'directory' && b.type === 'directory') return 1;
            return a.name.localeCompare(b.name);
        });
    }

    private static mapType(code: number): FileEntry['type'] {
        switch (code) {
            case 1: return 'file';
            case 2: return 'directory';
            case 3: return 'symlink';
            default: return 'other';
        }
    }
}
