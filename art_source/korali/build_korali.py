"""Reproducible Blender authoring/bake/export for the first Korali art study.
Run with C:/Blender/blender.exe --background --python this_file.
Generated stone basecolor is a source texture; all geometry/vein design is original.
"""
import bpy, bmesh, math, random, json
from pathlib import Path
from mathutils import Vector, noise

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(__file__).resolve().parent
OUTPUT = ROOT / 'assets' / 'korali_study'
OUTPUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
scene = bpy.context.scene
bpy.context.preferences.filepaths.save_version = 0
scene.render.engine = 'CYCLES'
scene.cycles.samples = 16
scene.cycles.bake_type = 'EMIT'
scene.render.bake.margin = 16
scene.render.bake.use_clear = True
scene.view_settings.view_transform = 'AgX'

# A stationary coordinate reference keeps geological veins continuous across chips.
anchor = bpy.data.objects.new('GeologicalCoordinates', None)
scene.collection.objects.link(anchor)
material = bpy.data.materials.new('Korali_Authoring')
material.use_nodes = True
material.use_backface_culling = True
nodes, links = material.node_tree.nodes, material.node_tree.links
nodes.clear()
def node(kind, name):
    n = nodes.new(kind); n.label = name; n.name = name; return n
def mathnode(op, a, b=0):
    n = node('ShaderNodeMath', op); n.operation = op
    for i, value in enumerate([a,b]):
        if isinstance(value, (int,float)): n.inputs[i].default_value = value
        else: links.new(value, n.inputs[i])
    return n.outputs[0]
def ramp(value, stops, name):
    n = node('ShaderNodeValToRGB', name)
    cr = n.color_ramp
    while len(cr.elements)>2: cr.elements.remove(cr.elements[-1])
    for i,(position,color) in enumerate(stops):
        e=cr.elements[i] if i<2 else cr.elements.new(position)
        e.position=position; e.color=(*color,1)
    links.new(value,n.inputs[0]); return n.outputs['Color']
def mix(factor,a,b,name):
    n=node('ShaderNodeMixRGB',name); n.blend_type='MIX'
    for socket,value in [(n.inputs[0],factor),(n.inputs[1],a),(n.inputs[2],b)]:
        if isinstance(value,(tuple,list)): socket.default_value=(*value,1)
        elif isinstance(value,(int,float)): socket.default_value=value
        else: links.new(value,socket)
    return n.outputs[0]
coord=node('ShaderNodeTexCoord','World aligned geology'); coord.object=anchor
vector=coord.outputs['Object']
sep=node('ShaderNodeSeparateXYZ','Stone coordinates'); links.new(vector,sep.inputs[0])
def texnoise(scale,detail,name):
    n=node('ShaderNodeTexNoise',name); n.inputs['Scale'].default_value=scale
    n.inputs['Detail'].default_value=detail; n.inputs['Roughness'].default_value=.7
    links.new(vector,n.inputs['Vector']); return n.outputs['Fac']
warp=mathnode('MULTIPLY', mathnode('SUBTRACT',texnoise(2.4,3,'Meandering mineral seams'),.5),.31)
fine=texnoise(27,3,'Mineral granules')
width=mathnode('ADD',mathnode('MULTIPLY',texnoise(4,2,'Variable seam width'),.038),.018)
def seam(ax,ay,az,offset,width_scale,gate=None):
    distance=mathnode('SUBTRACT',mathnode('ADD',mathnode('ADD',mathnode('MULTIPLY',sep.outputs['X'],ax),mathnode('MULTIPLY',sep.outputs['Y'],ay)),mathnode('MULTIPLY',sep.outputs['Z'],az)),offset)
    distance=mathnode('ABSOLUTE',mathnode('ADD',distance,warp))
    field=mathnode('DIVIDE',distance,mathnode('MULTIPLY',width,width_scale))
    mask=ramp(field,[(.4,(1,1,1)),(1.0,(0,0,0))],'Soft embedded seam')
    halo=ramp(mathnode('DIVIDE',field,2.5),[(.3,(1,1,1)),(1,(0,0,0))],'Oxidised seam boundary')
    if gate is not None:
        mask=mathnode('MULTIPLY',mask,gate); halo=mathnode('MULTIPLY',halo,gate)
    return mask,halo
main,main_halo=seam(.74,.3,-.62,-.30,1.6)
branch_gate=ramp(sep.outputs['Z'],[(.35,(0,0,0)),(.9,(1,1,1))],'Tapered branching seam')
branch,branch_halo=seam(-.40,.25,-.75,-1.20,.65,branch_gate)
small_gate=ramp(sep.outputs['X'],[(.1,(0,0,0)),(.85,(1,1,1))],'Broken subsidiary seam')
small,small_halo=seam(.35,.7,.7,.30,.6,small_gate)
mask=mathnode('MAXIMUM',mathnode('MAXIMUM',main,branch),small)
halo=mathnode('MAXIMUM',mathnode('MAXIMUM',main_halo,branch_halo),small_halo)
image=node('ShaderNodeTexImage','Generated slate surface')
image.image=bpy.data.images.load(str(SOURCE/'stone_basecolor_source.png'))
image.projection='BOX'; image.projection_blend=.25
scale=node('ShaderNodeVectorMath','Stone texture scale'); scale.operation='SCALE'
links.new(vector,scale.inputs[0]); scale.inputs['Scale'].default_value=.48
links.new(scale.outputs[0],image.inputs['Vector'])
stone=mix(.13,image.outputs['Color'],(.16,.19,.20),'Cool stone undertone')
oxidation=mix(fine,(.10,.064,.027),(.28,.19,.075),'Muted copper mineral boundary')
weathered=mix(mathnode('MULTIPLY',halo,.75),stone,oxidation,'Deposited mineral rim')
metal=mix(texnoise(8,2,'Iridescent mineral facets'),(.015,.19,.17),(.13,.63,.51),'Korali turquoise mineral')
color=mix(mask,weathered,metal,'Final base color')
roughness=mix(mask,(.83,.83,.83),(.29,.29,.29),'Mineral roughness contrast')
metallic=mathnode('MULTIPLY',mask,.72)
emission=mix(mathnode('MULTIPLY',mask,.10),(0,0,0),metal,'Restrained emission')
# Stone detail and shallow mineral recess are baked to a tangent normal map.
grey=node('ShaderNodeRGBToBW','Stone height from surface'); links.new(image.outputs['Color'],grey.inputs[0])
height=mathnode('ADD',mathnode('MULTIPLY',grey.outputs[0],.65),mathnode('MULTIPLY',fine,.08))
height=mathnode('SUBTRACT',height,mathnode('MULTIPLY',halo,.12))
bump=node('ShaderNodeBump','Surface relief'); bump.inputs['Strength'].default_value=.55
bump.inputs['Distance'].default_value=.12; links.new(height,bump.inputs['Height'])
bsdf=node('ShaderNodeBsdfPrincipled','Authoring surface')
links.new(color,bsdf.inputs['Base Color']); links.new(roughness,bsdf.inputs['Roughness'])
links.new(metallic,bsdf.inputs['Metallic']); links.new(bump.outputs['Normal'],bsdf.inputs['Normal'])
links.new(emission,bsdf.inputs['Emission Color']); bsdf.inputs['Emission Strength'].default_value=.2
out=node('ShaderNodeOutputMaterial','Material output'); links.new(bsdf.outputs[0],out.inputs['Surface'])

rocks=[]
def rock(name,location,scale,seed,hero=False):
    rng=random.Random(seed)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2,radius=1,location=(0,0,0))
    obj=bpy.context.object; obj.name=name
    for v in obj.data.vertices:
        c=v.co.copy()
        r=1+rng.uniform(-.11,.11)
        c.x*=scale[0]*r; c.y*=scale[1]*r; c.z*=scale[2]
        c.x+=c.z*.20
        c.z+=scale[2]*.91
        v.co=c
    bm=bmesh.new(); bm.from_mesh(obj.data)
    planes=[((0,0,.035),(0,0,-1))]
    if hero: planes += [((0,0,2.14),(-.25,.12,1)),((0,-.82,.7),(.13,-1,.13))]
    for center,normal in planes:
        bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.0001,plane_co=center,plane_no=normal,clear_outer=True)
        boundaries=[e for e in bm.edges if e.is_boundary]
        if boundaries: bmesh.ops.holes_fill(bm,edges=boundaries,sides=0)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bm.to_mesh(obj.data); bm.free()
    bevel=obj.modifiers.new('Chipped light-catching edges','BEVEL')
    bevel.width=.045 if hero else .024; bevel.segments=3
    bevel.affect='EDGES'; bevel.limit_method='ANGLE'; bevel.angle_limit=.32
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    sub=obj.modifiers.new('Surface tessellation','SUBSURF'); sub.subdivision_type='SIMPLE'; sub.levels=1
    bpy.ops.object.modifier_apply(modifier=sub.name)
    # Low amplitude geological erosion, preserving the broad fracture planes.
    for v in obj.data.vertices:
        p=v.co.copy()
        displacement=noise.noise_vector(p*8.7+Vector((seed,0,0)))*(.012 if hero else .007)
        if p.z>.08: v.co += displacement
    obj.location=location
    obj.data.materials.append(material)
    for face in obj.data.polygons: face.use_smooth=True
    weighted=obj.modifiers.new('Weighted fracture normals','WEIGHTED_NORMAL'); weighted.keep_sharp=True; weighted.weight=40
    bpy.ops.object.modifier_apply(modifier=weighted.name)
    rocks.append(obj)
    return obj
rock('Korali main fracture',(-.35,.1,0),(1.48,1.03,1.28),31,True)
rock('Detached mineral shoulder',(1.0,-.18,0),(.57,.72,.69),73)
rock('Basal flake',(-1.30,-.52,0),(.55,.36,.24),87)
rock('Detached chip',(1.28,-.95,0),(.27,.32,.19),91)
bpy.ops.object.select_all(action='DESELECT')
for obj in rocks: obj.select_set(True)
bpy.context.view_layer.objects.active=rocks[0]
bpy.ops.object.join()
asset=bpy.context.object; asset.name='Korali_Study_01'
bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=1.05,island_margin=.018)
bpy.ops.object.mode_set(mode='OBJECT')
# Keep an editable node-based source, with the source image packed.
image.image.pack()
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'korali_authoring.blend'))

target=node('ShaderNodeTexImage','Bake destination')
emit=node('ShaderNodeEmission','Bake transfer')
def bake(name,output,normal=False):
    result=bpy.data.images.new(name,width=2048,height=2048,alpha=False)
    if normal or name!='korali_albedo': result.colorspace_settings.name='Non-Color'
    target.image=result; nodes.active=target
    if normal: links.new(bsdf.outputs[0],out.inputs['Surface'])
    else:
        links.new(output,emit.inputs['Color']); links.new(emit.outputs[0],out.inputs['Surface'])
    bpy.ops.object.bake(type='NORMAL' if normal else 'EMIT',normal_space='TANGENT',margin=16)
    result.filepath_raw=str(OUTPUT/(name+'.png')); result.file_format='PNG'; result.save()
    print('BAKED',name,flush=True)
    return result
albedo=bake('korali_albedo',color)
normal_map=bake('korali_normal',None,True)
combine=node('ShaderNodeCombineColor','Packed surface channels'); combine.mode='RGB'
combine.inputs[0].default_value=1
links.new(roughness,combine.inputs[1]); links.new(metallic,combine.inputs[2])
orm=bake('korali_orm',combine.outputs[0])
glow=bake('korali_emission',emission)
# Portable PBR material used by the exported mesh, without procedural dependencies.
portable=bpy.data.materials.new('Korali_PBR'); portable.use_nodes=True; portable.use_backface_culling=True
pn=portable.node_tree.nodes; pl=portable.node_tree.links; pb=pn.get('Principled BSDF')
def portable_image(img):
    n=pn.new('ShaderNodeTexImage'); n.image=img; return n.outputs['Color']
pl.new(portable_image(albedo),pb.inputs['Base Color'])
nm=pn.new('ShaderNodeNormalMap'); pl.new(portable_image(normal_map),nm.inputs['Color']); pl.new(nm.outputs[0],pb.inputs['Normal'])
separate=pn.new('ShaderNodeSeparateColor'); separate.mode='RGB'; pl.new(portable_image(orm),separate.inputs[0])
pl.new(separate.outputs[1],pb.inputs['Roughness']); pl.new(separate.outputs[2],pb.inputs['Metallic'])
pl.new(portable_image(glow),pb.inputs['Emission Color']); pb.inputs['Emission Strength'].default_value=.2
asset.data.materials.clear(); asset.data.materials.append(portable)
asset.data.calc_loop_triangles()
bpy.ops.export_scene.gltf(filepath=str(OUTPUT/'korali_study.glb'),export_format='GLB',use_selection=True,export_tangents=True,export_animations=False,export_cameras=False,export_lights=False)
stats={'triangles':len(asset.data.loop_triangles),'vertices':len(asset.data.vertices),'texture_resolution':2048,'blender':bpy.app.version_string,'source':'art_source/korali/korali_authoring.blend','export':'assets/korali_study/korali_study.glb'}
(OUTPUT/'asset_info.json').write_text(json.dumps(stats,indent=2)+'\n')
print('EXPORT COMPLETE',stats,flush=True)
