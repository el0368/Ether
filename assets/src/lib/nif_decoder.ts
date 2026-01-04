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

    static decodeChunk(chunk: string | Uint8Array, root: string): FileEntry[] {
        let buffer: Uint8Array;
        if (typeof chunk === 'string') {
            const binaryString = atob(chunk);
            const length = binaryString.length;
            buffer = new Uint8Array(length);
            for (let i = 0; i < length; i++) {
                buffer[i] = binaryString.charCodeAt(i);
            }
        } else {
            buffer = chunk;
        }
        return this.decode(buffer, root);
    }

    static decode(buffer: Uint8Array, root: string): FileEntry[] {
        const entries: FileEntry[] = [];
        let offset = 0;

        // Safety check
        if (!buffer || buffer.byteLength === 0) return [];

        const view = new DataView(buffer.buffer, buffer.byteOffset, buffer.byteLength);

        while (offset < buffer.byteLength) {
            // Check for minimum header size (1 + 2 = 3 bytes)
            if (offset + 3 > buffer.byteLength) break;

            const typeCode = view.getUint8(offset);
            offset += 1;

            const len = view.getUint16(offset, true);
            offset += 2;

            if (offset + len > buffer.byteLength) {
                // WARN: Incomplete chunk received?
                // For now, break. In a perfect stream, chunks should be self-contained entries 
                // or we need a persistent buffer state.
                // Assuming NIF sends complete entries per chunk.
                console.warn("Incomplete entry in chunk");
                break;
            }

            const nameBytes = buffer.subarray(offset, offset + len);
            const name = this.decoder.decode(nameBytes);
            offset += len;

            entries.push({
                name: name,
                type: this.mapType(typeCode),
                path: `${root}/${name}`
            });
        }

        return entries;
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
