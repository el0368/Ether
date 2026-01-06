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
        try {
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
        } catch (e) {
            console.error("NifDecoder Error:", e);
            return [];
        }
    }

    static decode(buffer: Uint8Array, root: string): FileEntry[] {
        const entries: FileEntry[] = [];
        let offset = 0;

        // Safety check
        if (!buffer || buffer.byteLength < 1) return [];

        try {
            const view = new DataView(buffer.buffer, buffer.byteOffset, buffer.byteLength);

            while (offset < buffer.byteLength) {
                // Check for minimum header size (Type:u8 [1] + Len:u16 [2] = 3 bytes)
                if (offset + 3 > buffer.byteLength) {
                    if (offset < buffer.byteLength) {
                        console.warn(`Trailing bytes in chunk: ${buffer.byteLength - offset}`);
                    }
                    break;
                }

                const typeCode = view.getUint8(offset);
                const len = view.getUint16(offset + 1, true);
                
                // Advanced Safety: Validate length before moving offset
                if (offset + 3 + len > buffer.byteLength) {
                    console.error("Malformed entry: length exceeds buffer boundaries", { offset, len, total: buffer.byteLength });
                    break;
                }

                const nameBytes = buffer.subarray(offset + 3, offset + 3 + len);
                const name = this.decoder.decode(nameBytes);
                
                // Move offset past Type(1) + Len(2) + Name(len)
                offset += 3 + len;

                entries.push({
                    name: name,
                    type: this.mapType(typeCode),
                    path: `${root}/${name}`
                });
            }
        } catch (e) {
            console.error("Critical decoding failure in NifDecoder.decode:", e);
        }

        return entries;
    }

    private static mapType(code: number): FileEntry['type'] {
        switch (code) {
            case 1: return 'file';
            case 2: return 'directory';
            case 3: return 'symlink';
            default: 
                console.warn(`Unknown NIF type code: ${code}`);
                return 'other';
        }
    }
}
