"""Gate cohesion local stones. Original geometry; accepted generated sources.
Run Blender --background --factory-startup --python this_file. No add-ons.
Coordinates use Blender Z up; exports are placed at the original Godot anchors.
"""
import bpy, bmesh, math, random, json
from pathlib import Path
from mathutils import Vector

SRC=Path(__file__).resolve().parent
ROOT=SRC.parents[2]
OUT=ROOT/'assets/gate_cohesion'
OUT.mkdir(parents=True,exist_ok=True)
# Reuse the accepted fracture construction, without executing its asset build.
recipe=(ROOT/'art_source/rocks/build_formation.py').read_text()
namespace={'__file__':str(ROOT/'art_source/rocks/build_formation.py')}
exec(compile(recipe[:recipe.index("formation_piece('Primary")],str(ROOT/'art_source/rocks/build_formation.py'),'exec'),namespace)
piece=namespace['formation_piece']
scene=bpy.context.scene
scene.cycles.samples=8
assets={}

def join(parts,name):
    bpy.ops.object.select_all(action='DESELECT')
    for p in parts:p.select_set(True)
    bpy.context.view_layer.objects.active=parts[0]
    bpy.ops.object.join();o=bpy.context.object;o.name=name
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    t=o.modifiers.new('Bake triangulation','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=t.name)
    bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=1.05,island_margin=.002)
    bpy.ops.object.mode_set(mode='OBJECT')
    return o

for side in (-1,1):
    seed=101 if side<0 else 201
    # Broad oblique fracture planes, embedded foot, broken shoulder and fallen spall.
    # Fit the former 4 x 3.5 x 5.8 envelope rather than enlarge the scenery.
    parts=[piece('Weathered flanker core',(-.22*side,.30,-.12),(1.62,2.40,3.16),seed,True)]
    parts.append(piece('Separated shoulder joint',(.98*side,-.10,-.13),(.79,1.58,2.25),seed+1,True))
    parts.append(piece('Buried fracture toe',(-.54*side,-1.62,-.13),(1.10,.66,.80),seed+2,True))
    for i,(x,y,w) in enumerate([(-1.42,-1.77,.28),(.78,-2.22,.35),(1.62,-.90,.23)]):
        parts.append(piece('Local fallen sandstone chip',(x,y,-.07),(w,w*.72,w*.63),seed+3+i))
    assets['flanker_'+('left' if side<0 else 'right')]=join(parts,'Fractured sanctuary flanker')

def marker(side):
    # Worked slab with battered shoulders. Front is planar to receive the retained sigil.
    outline=[(-.45,-.10),(.44,-.10),(.52,.33),(.43,1.78),(.24,2.34),
             (-.12,2.39),(-.30,2.24),(-.49,1.93),(-.54,.37)]
    if side>0:outline=[(x,z+(0.05 if i in (4,5) else 0)) for i,(x,z) in enumerate(outline)]
    n=len(outline);vs=[(x,y,z) for y in (-.48,.30) for x,z in outline]
    fs=[tuple(range(n-1,-1,-1)),tuple(range(n,n*2))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    me=bpy.data.meshes.new('Chipped marker slab');me.from_pydata(vs,[],fs);me.update()
    o=bpy.data.objects.new('Worked wayside stone',me);scene.collection.objects.link(o)
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    bm=bmesh.new();bm.from_mesh(me);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(me);bm.free()
    bevel=o.modifiers.new('Abraded arris','BEVEL');bevel.width=.055;bevel.segments=3
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    for p in o.data.polygons:p.use_smooth=True
    normal=o.modifiers.new('Worked face normals','WEIGHTED_NORMAL');normal.keep_sharp=True
    bpy.ops.object.modifier_apply(modifier=normal.name)
    chip=piece('Marker foot spall',(.43*side,-.21,-.04),(.20,.20,.15),310+side)
    return join([o,chip],'Worn sigil marker')

assets['marker_left']=marker(-1);assets['marker_right']=marker(1)

authoring={}
for name,o in assets.items():
    rock=name.startswith('flanker')
    mat=bpy.data.materials.new(name+' authoring');mat.use_nodes=True
    ns=mat.node_tree.nodes;ls=mat.node_tree.links;p=ns.get('Principled BSDF')
    tex=ns.new('ShaderNodeTexImage')
    tex.image=bpy.data.images.load(str(ROOT/('art_source/terrain/cliff_source.png' if rock else 'art_source/gate/v2/aged_limestone_source.png')),check_existing=True);tex.image.pack()
    coord=ns.new('ShaderNodeTexCoord');scale=ns.new('ShaderNodeVectorMath');scale.operation='SCALE';scale.inputs['Scale'].default_value=.36 if rock else .65
    ls.new(coord.outputs['Object'],scale.inputs[0]);ls.new(scale.outputs[0],tex.inputs[0]);tex.projection='BOX';tex.projection_blend=.16
    # Same grade as the integrated Terrain 01 cliffs (natural rock) or the
    # revised Gate stone (worked markers), so Lighting 01 treats them alike.
    calm=ns.new('ShaderNodeMixRGB');calm.inputs[0].default_value=.27 if rock else 0
    calm.inputs[2].default_value=(.43,.30,.20,1);ls.new(tex.outputs[0],calm.inputs[1])
    tint=ns.new('ShaderNodeMixRGB');tint.blend_type='MULTIPLY';tint.inputs[0].default_value=1
    tint.inputs[2].default_value=(.76,.82,.88,1) if rock else (.86,.87,.88,1)
    ls.new(calm.outputs[0],tint.inputs[1]);color=tint.outputs[0]
    # Warm accumulated dust is height-limited, with contact occlusion kept local.
    separate=ns.new('ShaderNodeSeparateXYZ');ls.new(coord.outputs['Object'],separate.inputs[0])
    height=ns.new('ShaderNodeMapRange');height.inputs['From Min'].default_value=0; height.inputs['From Max'].default_value=1.1
    height.inputs['To Min'].default_value=.34;height.inputs['To Max'].default_value=0
    ls.new(separate.outputs['Z'],height.inputs[0])
    dust=ns.new('ShaderNodeMixRGB');dust.inputs[2].default_value=(.55,.41,.25,1)
    ls.new(height.outputs[0],dust.inputs[0]);ls.new(color,dust.inputs[1]);color=dust.outputs[0]
    ao=ns.new('ShaderNodeAmbientOcclusion');ao.inputs['Distance'].default_value=.25;ao.samples=24;ao.only_local=True
    remap=ns.new('ShaderNodeMapRange');remap.inputs['To Min'].default_value=.58
    ls.new(ao.outputs['AO'],remap.inputs[0])
    mix=ns.new('ShaderNodeMixRGB');mix.blend_type='MULTIPLY';mix.inputs[0].default_value=1
    ls.new(color,mix.inputs[1]);ls.new(remap.outputs[0],mix.inputs[2]);color=mix.outputs[0]
    ls.new(color,p.inputs['Base Color'])
    bump=ns.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.36;bump.inputs['Distance'].default_value=.045 if rock else .03
    ls.new(tex.outputs[0],bump.inputs['Height']);ls.new(bump.outputs[0],p.inputs['Normal'])
    gray=ns.new('ShaderNodeRGBToBW');ls.new(tex.outputs[0],gray.inputs[0])
    rough=ns.new('ShaderNodeMapRange');rough.inputs['To Min'].default_value=.84;rough.inputs['To Max'].default_value=.97
    ls.new(gray.outputs[0],rough.inputs[0]);ls.new(rough.outputs[0],p.inputs['Roughness'])
    o.data.materials.clear();o.data.materials.append(mat);authoring[name]=(mat,color,rough.outputs[0])

bpy.ops.wm.save_as_mainfile(filepath=str(SRC/'neighbors_authoring.blend'))
stats={}
for name,o in assets.items():
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    mat,color,rough=authoring[name];ns=mat.node_tree.nodes;ls=mat.node_tree.links
    p=ns.get('Principled BSDF');out=ns.get('Material Output');target=ns.new('ShaderNodeTexImage');emit=ns.new('ShaderNodeEmission')
    resolution=2048 if name.startswith('flanker') else 1024;maps={}
    for channel,socket in [('albedo',color),('normal',None),('roughness',rough)]:
        img=bpy.data.images.new(name+'_'+channel,width=resolution,height=resolution,alpha=False)
        if channel!='albedo':img.colorspace_settings.name='Non-Color'
        target.image=img;ns.active=target
        if channel=='normal':ls.new(p.outputs[0],out.inputs[0])
        else:ls.new(socket,emit.inputs['Color']);ls.new(emit.outputs[0],out.inputs[0])
        bpy.ops.object.bake(type='NORMAL' if channel=='normal' else 'EMIT',margin=8,normal_space='TANGENT')
        img.filepath_raw=str(OUT/(img.name+'.png'));img.file_format='PNG';img.save();maps[channel]=img
        print('BAKED',img.name,flush=True)
    # Names select the matching Lighting 01 recipe in scripts/lighting_profile.gd.
    portable=bpy.data.materials.new('cliff portable PBR' if name.startswith('flanker') else 'Gate II stone PBR');portable.use_nodes=True
    ns=portable.node_tree.nodes;ls=portable.node_tree.links;p=ns.get('Principled BSDF')
    for channel,img in maps.items():
        t=ns.new('ShaderNodeTexImage');t.image=img
        if channel=='normal':
            normal=ns.new('ShaderNodeNormalMap');ls.new(t.outputs[0],normal.inputs[0+1]);ls.new(normal.outputs[0],p.inputs['Normal'])
        else:ls.new(t.outputs[0],p.inputs['Base Color' if channel=='albedo' else 'Roughness'])
    o.data.materials.clear();o.data.materials.append(portable)
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True,export_tangents=True,export_animations=False,export_cameras=False,export_lights=False)
    o.data.calc_loop_triangles();stats[name]={'triangles':len(o.data.loop_triangles),'resolution':resolution}
(OUT/'neighbors_info.json').write_text(json.dumps(stats,indent=2)+'\n')
print('NEIGHBORS COMPLETE',stats,flush=True)
