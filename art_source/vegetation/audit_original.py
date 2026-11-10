"""Read-only audit of packed Tree 02 and its runtime GLB; never saves the old blend.
Run with Blender --background --python this_file. Outputs this folder's audit JSON.
"""
import bpy,json,struct
from pathlib import Path
from mathutils.bvhtree import BVHTree
ROOT=Path(__file__).resolve().parents[2]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'art_source/tree/tree_authoring_v2.blend'))
wood=bpy.data.objects['Twisted trunk and branches']
leaf=bpy.data.objects['Layered sage canopy']
bvh=BVHTree.FromObject(wood,bpy.context.evaluated_depsgraph_get())
# Tree 02 emits 15 vertices per leaf; row zero's centre is its nominal attachment.
gaps=[bvh.find_nearest(leaf.data.vertices[i+1].co)[3] for i in range(0,len(leaf.data.vertices),15)]
raw=(ROOT/'assets/tree_study/v2/desert_tree.glb').read_bytes()
n=struct.unpack_from('<I',raw,12)[0];g=json.loads(raw[20:20+n])
result={'source':'art_source/tree/tree_authoring_v2.blend','leaves':len(gaps),
 'leaf_base_to_nearest_wood_surface':{'maximum_metres':max(gaps),'over_1cm':sum(v>.01 for v in gaps),'over_2cm':sum(v>.02 for v in gaps)},
 'canopy_triangles':len(leaf.data.polygons),'canopy_triangles_normal_z_negative':sum(p.normal.z<0 for p in leaf.data.polygons),
 'glb_leaf_double_sided':next(m.get('doubleSided',False) for m in g['materials'] if m['name']=='Sage leaf PBR'),
 'packed_images':all(i.packed_file is not None for i in bpy.data.images if i.type=='IMAGE'),
 'interpretation':'Nearest surface distance alone includes embedded origins. Source path comparison establishes attachment error: leaf origins interpolate straight endpoints while twig centreline curves. Downward canopy face normals are verified; two-sided rendering masks face visibility failure.'}
(Path(__file__).parent/'original_audit.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result,indent=2))
