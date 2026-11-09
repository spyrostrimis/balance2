"""Original sandstone formation, authored and baked in Blender 5.2.
Run with Blender --background --factory-startup --python this_file.
No external textures, meshes, add-ons or generated images are required.
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
    count=9
    angles=[i*math.tau/count+rng.uniform(-.08,.08) for i in range(count)]
    radii=[rng.uniform(.86,1.12) for i in range(count)]
    levels=[(0,.92),(.12,1.0),(.38,.95),(.43,1.02),(.47,.89),(.72,.90),(.78,.80),(1,.70)]
    vertices=[]; faces=[]
    for k,(height,size) in enumerate(levels):
        for i,angle in enumerate(angles):
            radius=radii[i]*size+rng.uniform(-.045,.045)
            x=math.cos(angle)*radius*scale[0]+height*.15
            y=math.sin(angle)*radius*scale[1]-height*.12
            z=max(.015,height*scale[2]+(.035*math.sin(angle*2+seed)-x*.07 if k>0 else 0))
            if k==len(levels)-1: z+=scale[2]*(.10*math.sin(angle+seed)+.07*math.cos(angle*3))
            vertices.append((x,y,z))
    for k in range(len(levels)-1):
        for i in range(count):
            j=(i+1)%count
            faces.append((k*count+i,k*count+j,(k+1)*count+j,(k+1)*count+i))
    faces.append(tuple(reversed(range(count))))
    faces.append(tuple((len(levels)-1)*count+i for i in range(count)))
    mesh=bpy.data.meshes.new(name); mesh.from_pydata(vertices,[],faces); mesh.update()
    obj=bpy.data.objects.new(name,mesh); scene.collection.objects.link(obj)
    bpy.context.view_layer.objects.active=obj; obj.select_set(True)
    bm=bmesh.new(); bm.from_mesh(mesh)
    # Angled cleavage planes break the silhouette and interrupt sediment bands.
    planes=[((scale[0]*.69,-scale[1]*.51,.8*scale[2]),(.8,-.7,.13))]
    if main:
        planes.append(((-scale[0]*.7,0,.9*scale[2]),(-.8,.15,.4)))
        planes.append(((0,-scale[1]*.15,scale[2]*.98),(.28,-.25,1)))
    for center,normal in planes:
        bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.0001,plane_co=center,plane_no=normal,clear_outer=True)
        boundaries=[e for e in bm.edges if e.is_boundary]
        if boundaries: bmesh.ops.holes_fill(bm,edges=boundaries,sides=0)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(mesh); bm.free()
    bevel=obj.modifiers.new('Weathered edges','BEVEL'); bevel.width=.028 if main else .017
    bevel.segments=2; bevel.limit_method='ANGLE'; bevel.angle_limit=.25
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

formation_piece('Primary fractured sandstone',(-.40,.10,0),(1.16,.88,2.05),122,True)
formation_piece('Broken shoulder',(.87,.36,0),(.68,.64,1.28),151,True)
formation_piece('Fallen foreground slab',(-.72,-.86,0),(.77,.42,.36),183)
formation_piece('Detached lower block',(.85,-.62,0),(.40,.38,.49),202)
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
weather=texture(2.2,4); grit=texture(95,2)
split=node('ShaderNodeSeparateXYZ','Bedding height'); links.new(co,split.inputs[0])
height=mathnode('ADD',split.outputs['Z'],mathnode('MULTIPLY',weather,.14))
bands=mathnode('MULTIPLY',mathnode('ADD',mathnode('SINE',mathnode('MULTIPLY',height,37)),1),.5)
layer=mathnode('POWER',bands,7)
base=ramp(weather,[(.18,(.12,.058,.028,1)),(.82,(.46,.29,.14,1))])
color=mix(base,(.14,.065,.032,1),mathnode('MULTIPLY',layer,.28))
edge=node('ShaderNodeNewGeometry','Weathered exposed edges')
edge_mask=mathnode('MULTIPLY',mathnode('MAXIMUM',mathnode('SUBTRACT',edge.outputs['Pointiness'],.5),0),3)
color=mix(color,(.57,.40,.23,1),edge_mask)
color=mix(color,ramp(grit,[(.2,(.17,.09,.045,1)),(.8,(.5,.34,.19,1))]),.10)
links.new(color,bsdf.inputs['Base Color'])
height_detail=mathnode('ADD',mathnode('MULTIPLY',grit,.3),mathnode('MULTIPLY',weather,.6))
height_detail=mathnode('SUBTRACT',height_detail,mathnode('MULTIPLY',layer,.12))
bump=node('ShaderNodeBump','Stone pores and sediment'); bump.inputs['Strength'].default_value=.45; bump.inputs['Distance'].default_value=.035
links.new(height_detail,bump.inputs['Height']); links.new(bump.outputs[0],bsdf.inputs['Normal'])
roughness=mathnode('ADD',.80,mathnode('MULTIPLY',weather,.15)); links.new(roughness,bsdf.inputs['Roughness'])
asset.data.materials.clear(); asset.data.materials.append(mat)
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT'); bpy.ops.uv.smart_project(angle_limit=1.05,island_margin=.015); bpy.ops.object.mode_set(mode='OBJECT')
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
stats={'blender':bpy.app.version_string,'triangles':len(asset.data.loop_triangles),'texture_resolution':2048,'source':'art_source/rocks/sandstone_authoring.blend','provenance':'Original geometry and procedural baked surfaces; no third-party files.'}
(OUT/'asset_info.json').write_text(json.dumps(stats,indent=2)+'\n')
print('FORMATION COMPLETE',stats,flush=True)
