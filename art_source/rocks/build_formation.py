"""Original sandstone formation, authored and baked in Blender 5.2.
Run with Blender --background --factory-startup --python this_file.
Uses the generated sandstone source image, with original mesh construction.
"""
import bpy, bmesh, math, random, json
from pathlib import Path
from mathutils import Vector, noise

ROOT=Path(__file__).resolve().parents[2]
SOURCE=Path(__file__).resolve().parent
OUT=ROOT/'assets'/'rock_study'
OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
scene=bpy.context.scene; scene.render.engine='CYCLES'; scene.cycles.samples=12
rocks=[]

def formation_piece(name,position,scale,seed,main=False):
    rng=random.Random(seed)
    # Irregular fracture mass, following the successful Korali construction.
    # No stacked radial rings or repeating ledges.
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2,radius=1)
    obj=bpy.context.object; obj.name=name; mesh=obj.data
    for vertex in mesh.vertices:
        c=vertex.co.copy(); radial=rng.uniform(.88,1.10)
        vertex.co=Vector((c.x*scale[0]*radial+c.z*.18,
                          c.y*scale[1]*radial+c.x*.08,
                          (c.z*.59+.48)*scale[2]))
    bm=bmesh.new(); bm.from_mesh(mesh)
    # Broad oblique fracture faces, with a flat buried base.
    planes=[((0,0,.025),(0,0,-1))]
    if main:
        planes.append(((0,-scale[1]*.73,scale[2]*.45),(.18,-1,.14)))
        planes.append(((scale[0]*.78,0,scale[2]*.40),(1,.14,.10)))
        planes.append(((0,0,scale[2]*.91),(-.21,.18,1)))
    for center,normal in planes:
        bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.0001,plane_co=center,plane_no=normal,clear_outer=True)
        boundaries=[e for e in bm.edges if e.is_boundary]
        if boundaries: bmesh.ops.holes_fill(bm,edges=boundaries,sides=0)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(mesh); bm.free()
    bevel=obj.modifiers.new('Weathered edges','BEVEL'); bevel.width=.038 if main else .02
    bevel.segments=3; bevel.limit_method='ANGLE'; bevel.angle_limit=.32
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    if main:
        sub=obj.modifiers.new('Erosion surface','SUBSURF'); sub.subdivision_type='SIMPLE'; sub.levels=1
        bpy.ops.object.modifier_apply(modifier=sub.name)
    for vertex in obj.data.vertices:
        if vertex.co.z>.05:
            vertex.co+=noise.noise_vector(vertex.co*9+Vector((seed,0,0)))*(.013 if main else .008)
    for polygon in obj.data.polygons: polygon.use_smooth=True
    normals=obj.modifiers.new('Fracture plane normals','WEIGHTED_NORMAL'); normals.keep_sharp=True; normals.weight=50
    bpy.ops.object.modifier_apply(modifier=normals.name)
    obj.location=position; rocks.append(obj); obj.select_set(False)
    return obj

formation_piece('Primary fractured sandstone',(-.38,.12,0),(1.23,.91,2.24),122,True)
shoulder=formation_piece('Broken shoulder',(1.02,.28,0),(.67,.67,1.38),151,True)
shoulder.rotation_euler.z=.36
formation_piece('Fallen foreground slab',(-.85,-.73,0),(.69,.43,.38),183)
formation_piece('Detached lower block',(.73,-.83,0),(.42,.38,.51),202)
for i,(x,y,s) in enumerate([(-1.45,-.60,.19),(-1.05,-1.19,.16),(.25,-1.1,.19),(1.35,-.37,.15),(1.35,.82,.22)]):
    part=formation_piece('Scattered chip %02d'%i,(x,y,0),(s,s*.78,s*.66),221+i)
    part.rotation_euler.z=i*.8
bpy.ops.object.select_all(action='DESELECT')
for rock in rocks: rock.select_set(True)
bpy.context.view_layer.objects.active=rocks[0]; bpy.ops.object.join()
asset=bpy.context.object; asset.name='Basin sandstone formation'
bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)

mat=bpy.data.materials.new('Sandstone authoring'); mat.use_nodes=True
nodes=mat.node_tree.nodes; links=mat.node_tree.links
nodes.clear(); out=nodes.new('ShaderNodeOutputMaterial'); bsdf=nodes.new('ShaderNodeBsdfPrincipled')
links.new(bsdf.outputs[0],out.inputs['Surface']); bsdf.inputs['Roughness'].default_value=.88
def node(kind,name):
    n=nodes.new(kind); n.label=name; return n
def mathnode(op,a,b=None):
    n=node('ShaderNodeMath',op); n.operation=op
    for i,v in enumerate([a,b]):
        if v is None: continue
        if isinstance(v,(int,float)): n.inputs[i].default_value=v
        else: links.new(v,n.inputs[i])
    return n.outputs[0]
def mix(a,b,amount):
    n=node('ShaderNodeMixRGB','Surface blend'); n.blend_type='MIX'
    for i,v in enumerate([amount,a,b]):
        if isinstance(v,(int,float,tuple)): n.inputs[i].default_value=v
        else: links.new(v,n.inputs[i])
    return n.outputs[0]
def ramp(socket,colors):
    n=node('ShaderNodeValToRGB','Sandstone palette')
    for e,(position,color) in zip(n.color_ramp.elements,colors): e.position=position; e.color=color
    links.new(socket,n.inputs[0]); return n.outputs[0]
coords=node('ShaderNodeTexCoord','Stone coordinates')
co=coords.outputs['Object']
def texture(scale,detail):
    n=node('ShaderNodeTexNoise','Geological grain'); n.inputs['Scale'].default_value=scale; n.inputs['Detail'].default_value=detail
    links.new(co,n.inputs['Vector']); return n.outputs['Fac']
weather=texture(2.2,4); grit=texture(50,2)
image=node('ShaderNodeTexImage','Generated sandstone fracture surface')
image.image=bpy.data.images.load(str(SOURCE/'sandstone_basecolor_source.png'))
image.projection='BOX'; image.projection_blend=.22
mapping=node('ShaderNodeVectorMath','Large readable texture plates'); mapping.operation='SCALE'
mapping.inputs['Scale'].default_value=.45; links.new(co,mapping.inputs[0]); links.new(mapping.outputs[0],image.inputs['Vector'])
base=mix(image.outputs['Color'],(.25,.19,.14,1),.08)
edge=node('ShaderNodeNewGeometry','Weathered exposed edges')
edge_mask=mathnode('MULTIPLY',mathnode('MAXIMUM',mathnode('SUBTRACT',edge.outputs['Pointiness'],.5),0),3)
color=mix(base,(.57,.40,.23,1),mathnode('MULTIPLY',edge_mask,.25))
tint=node('ShaderNodeMixRGB','Weathered sandstone value'); tint.blend_type='MULTIPLY'; tint.inputs[0].default_value=1
tint.inputs[2].default_value=(.70,.74,.79,1); links.new(color,tint.inputs[1]); color=tint.outputs[0]
links.new(color,bsdf.inputs['Base Color'])
grey=node('ShaderNodeRGBToBW','Relief aligned with visible stone fractures'); links.new(image.outputs['Color'],grey.inputs[0])
height_detail=mathnode('ADD',mathnode('MULTIPLY',grey.outputs[0],.65),mathnode('MULTIPLY',grit,.035))
bump=node('ShaderNodeBump','Stone chips and fracture relief'); bump.inputs['Strength'].default_value=.55; bump.inputs['Distance'].default_value=.11
links.new(height_detail,bump.inputs['Height']); links.new(bump.outputs[0],bsdf.inputs['Normal'])
roughness=mathnode('ADD',.80,mathnode('MULTIPLY',weather,.15)); links.new(roughness,bsdf.inputs['Roughness'])
asset.data.materials.clear(); asset.data.materials.append(mat)
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT'); bpy.ops.uv.smart_project(angle_limit=1.05,island_margin=.015); bpy.ops.object.mode_set(mode='OBJECT')
image.image.pack()
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'sandstone_authoring.blend'))
destination=node('ShaderNodeTexImage','Bake output'); emission=node('ShaderNodeEmission','Unlit bake transfer')
def bake(name,socket,normal=False):
    image=bpy.data.images.new(name,width=2048,height=2048,alpha=False)
    if normal or 'roughness' in name: image.colorspace_settings.name='Non-Color'
    destination.image=image; nodes.active=destination
    if normal: links.new(bsdf.outputs[0],out.inputs['Surface'])
    else:
        links.new(socket,emission.inputs['Color']); links.new(emission.outputs[0],out.inputs['Surface'])
    bpy.ops.object.bake(type='NORMAL' if normal else 'EMIT',margin=16,normal_space='TANGENT')
    image.filepath_raw=str(OUT/(name+'.png')); image.file_format='PNG'; image.save()
    print('BAKED '+name,flush=True)
    return image
albedo=bake('sandstone_albedo',color)
normal=bake('sandstone_normal',None,True)
rough=bake('sandstone_roughness',roughness)
portable=bpy.data.materials.new('Weathered sandstone PBR'); portable.use_nodes=True
pn=portable.node_tree.nodes; pl=portable.node_tree.links; p=pn.get('Principled BSDF')
def image_node(img):
    n=pn.new('ShaderNodeTexImage'); n.image=img; return n.outputs[0]
pl.new(image_node(albedo),p.inputs['Base Color'])
normal_node=pn.new('ShaderNodeNormalMap'); pl.new(image_node(normal),normal_node.inputs['Color']); pl.new(normal_node.outputs[0],p.inputs['Normal'])
pl.new(image_node(rough),p.inputs['Roughness'])
asset.data.materials.clear(); asset.data.materials.append(portable)
tri=asset.modifiers.new('Portable triangles','TRIANGULATE'); bpy.ops.object.modifier_apply(modifier=tri.name)
bpy.ops.export_scene.gltf(filepath=str(OUT/'sandstone_formation.glb'),export_format='GLB',use_selection=True,export_tangents=True,export_animations=False,export_cameras=False,export_lights=False)
asset.data.calc_loop_triangles()
stats={'blender':bpy.app.version_string,'revision':2,'triangles':len(asset.data.loop_triangles),'texture_resolution':2048,'source':'art_source/rocks/sandstone_authoring.blend','provenance':'Original geometry; generated sandstone basecolor source baked with authored surface relief. See TEXTURE_SOURCE.md.'}
(OUT/'asset_info.json').write_text(json.dumps(stats,indent=2)+'\n')
print('FORMATION COMPLETE',stats,flush=True)
