/**
 * NifDecoder - Zero-Copy Binary Protocol Parser
 * Decodes the [Type:u8][Len:u16][Path:Bytes] format from Aether.Native
 */

export class NifDecoder {
    static decoder = new TextDecoder('utf-8');

    static decodeChunk(chunk, root) {
        try {
            let buffer;
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

    static decode(buffer, root) {
        const entries = [];
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

    static mapType(code) {
        switch (code) {
            case 1: return 'file';
            case 2: return 'directory';
            case 3: return 'symlink';
            default: return 'other';
        }
    }
}
