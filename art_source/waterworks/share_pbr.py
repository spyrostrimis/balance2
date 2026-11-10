"""Give the kit GLBs shared external PNGs instead of embedding five atlas copies.
Uses only stdlib; keeps accessor/bufferView references correct after repacking.
Run directly after build, or imported by build_waterworks.py.
"""
import json, struct
from pathlib import Path

def share_pbr(path):
    data=path.read_bytes(); size=struct.unpack_from('<I',data,12)[0]
    doc=json.loads(data[20:20+size]); binary=data[28+size:]
    embedded={img['bufferView'] for img in doc.get('images',[]) if 'bufferView' in img}
    if not embedded:return
    for img in doc['images']:
        view=doc['bufferViews'][img.pop('bufferView')]
        offset=view.get('byteOffset',0); contents=binary[offset:offset+view['byteLength']]
        # Exporter's roughness PNG packs metallic/roughness in glTF channels.
        name=img['name'].replace('_roughness','_surface')+'.png'
        (path.parent/name).write_bytes(contents)
        img['uri']=name; img.pop('mimeType',None)
    packed=bytearray(); remap={}; views=[]
    for index,view in enumerate(doc['bufferViews']):
        if index in embedded:continue
        packed.extend(b'\0'*((-len(packed))%4)); offset=view.get('byteOffset',0)
        content=binary[offset:offset+view['byteLength']]
        view['byteOffset']=len(packed); remap[index]=len(views)
        views.append(view); packed.extend(content)
    for accessor in doc['accessors']:
        if 'bufferView' in accessor:accessor['bufferView']=remap[accessor['bufferView']]
        assert 'sparse' not in accessor, 'Add sparse accessor remapping before using sparse meshes'
    doc['bufferViews']=views; doc['buffers'][0]['byteLength']=len(packed)
    encoded=json.dumps(doc,separators=(',',':')).encode(); encoded+=b' '*((-len(encoded))%4)
    packed.extend(b'\0'*((-len(packed))%4))
    path.write_bytes(struct.pack('<III',0x46546c67,2,28+len(encoded)+len(packed))+
                    struct.pack('<II',len(encoded),0x4e4f534a)+encoded+
                    struct.pack('<II',len(packed),0x004e4942)+packed)

if __name__=='__main__':
    out=Path(__file__).resolve().parents[2]/'assets/waterworks_study'
    for path in out.glob('*.glb'):share_pbr(path)
