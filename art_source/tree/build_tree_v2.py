"""Revision 02: original tree geometry with generated bark and leaf sources.
Blender 5.2 authoring and portable PBR baking. See TEXTURE_SOURCES.md.
Run: C:/Blender/blender.exe --background --factory-startup --python this_file
"""
import bpy, bmesh, math, random, json
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(__file__).resolve().parent
OUT = ROOT / 'assets/tree_study/v2'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version = 0
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 8
scene.render.bake.margin = 12
rng = random.Random(8164)

def material(name, color, roughness=.8):
    m=bpy.data.materials.new(name); m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value=(*color,1)
    p.inputs['Roughness'].default_value=roughness
    return m

class Geometry:
    def __init__(self): self.vertices=[]; self.faces=[]; self.uv=[]; self.colors=[]
    def vertex(self,p,uv=(0,0),color=(1,1,1,1)):
        self.vertices.append(tuple(p)); self.uv.append(uv); self.colors.append(color)
        return len(self.vertices)-1
    def make(self,name,mat,smooth=True):
        mesh=bpy.data.meshes.new(name); mesh.from_pydata(self.vertices,[],self.faces); mesh.update()
        obj=bpy.data.objects.new(name,mesh); scene.collection.objects.link(obj)
        mesh.materials.append(mat)
        uvs=mesh.uv_layers.new(name='UVMap')
        col=mesh.color_attributes.new(name='Tint',type='FLOAT_COLOR',domain='CORNER')
        for poly in mesh.polygons:
            poly.use_smooth=smooth
            for loop in poly.loop_indices:
                index=mesh.loops[loop].vertex_index
                uvs.data[loop].uv=self.uv[index]; col.data[loop].color=self.colors[index]
        if self is wood:
            # Merge coincident seam positions while retaining per-corner UVs.
            bm=bmesh.new(); bm.from_mesh(mesh)
            bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.00001)
            bm.to_mesh(mesh); bm.free(); mesh.update()
        return obj

wood=Geometry(); leaves=Geometry(); succulents=Geometry(); petals=Geometry(); stems=Geometry(); hearts=Geometry()

def tube(geo,points,radii,sides=8,steps=4):
    points=[Vector(p) for p in points]; ring_ids=[]
    distance=0.0; previous_point=None
    for segment in range(len(points)-1):
        a=points[max(0,segment-1)]; b=points[segment]; c=points[segment+1]; d=points[min(len(points)-1,segment+2)]
        for step in range(steps + (1 if segment==len(points)-2 else 0)):
            t=step/steps
            p=.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t)
            if previous_point is not None: distance+=(p-previous_point).length
            previous_point=p.copy()
            tangent=(c-b).normalized(); across=tangent.cross(Vector((0,1,0))).normalized()
            if across.length < .01: across=Vector((1,0,0))
            other=tangent.cross(across).normalized()
            radius=radii[segment]*(1-t)+radii[segment+1]*t
            ids=[]
            for j in range(sides+1):
                angle=j*math.tau/sides
                ridged=radius*(1+.07*math.sin(angle*5+segment*.4))
                ids.append(geo.vertex(p+(across*math.cos(angle)+other*math.sin(angle))*ridged,(j/sides*math.tau*radii[0]/.9,distance/.9)))
            ring_ids.append(ids)
    for a,b in zip(ring_ids[:-1],ring_ids[1:]):
        for j in range(sides): geo.faces.append((a[j],a[j+1],b[j+1],b[j]))
    geo.faces.append(tuple(reversed(ring_ids[0][:-1]))); geo.faces.append(tuple(ring_ids[-1][:-1]))

def leaf(geo,origin,direction,length,width,tint,curl=.13,fold=.07):
    origin=Vector(origin); forward=Vector(direction).normalized()
    across=forward.cross(Vector((0,0,1))).normalized()
    if across.length<.01: across=Vector((1,0,0))
    up=across.cross(forward).normalized()
    rows=[]
    for i in range(5):
        t=i/4
        span=max(.012,math.sin(math.pi*t)**.85)*width
        center=origin+forward*length*t+up*(math.sin(math.pi*t)*length*curl-t*t*length*.09)
        row=[]
        for j in range(3):
            side=j-1
            p=center+across*span*side + up*(fold*length*math.sin(math.pi*t)*(1-abs(side)))
            row.append(geo.vertex(p,(j/2,t),(*tint,1)))
        rows.append(row)
    for a,b in zip(rows[:-1],rows[1:]):
        for j in range(2): geo.faces.append((a[j],b[j],b[j+1],a[j+1]))

# Tapered, bowed trunk and spreading roots. Branches remain visible below crown.
trunk=[(0,0,.03),(-.13,.03,.42),(.03,.05,.95),(.22,0,1.48),(.1,.04,2.0),(.3,.05,2.6)]
tube(wood,trunk,[.30,.24,.19,.16,.11,.025],14,5)
for angle in [.1,1.6,2.8,4.2,5.4]:
    direction=Vector((math.cos(angle),math.sin(angle),0))
    tube(wood,[(0,0,.33),direction*.32+Vector((0,0,.13)),direction*.72+Vector((0,0,.045)),direction*.98+Vector((0,0,.005))],[.12,.10,.045,.008],8,4)

crowns=[(Vector((-.85,.15,2.7)),1.0),(Vector((.85,.32,3.4)),1.02),(Vector((.25,-.95,2.95)),.92),(Vector((.1,1.0,2.9)),.88)]
leaf_count=0
for crown_index,(center,radius) in enumerate(crowns):
    base=Vector(trunk[3 if crown_index%2==0 else 4])
    bend=base.lerp(center,.55)+Vector((0,0,-.2))
    tube(wood,[base,bend,center],[.13,.08,.035],10,5)
    for branch in range(10):
        angle=branch*math.tau/10+rng.uniform(-.2,.2)+crown_index*.6
        radial=Vector((math.cos(angle),math.sin(angle),0))
        end=center+radial*radius*rng.uniform(.65,1.0)+Vector((0,0,rng.uniform(-.05,.35)))
        branch_base=center-radial*.13-Vector((0,0,.2))
        tube(wood,[branch_base,branch_base.lerp(end,.5)-Vector((0,0,.12)),end],[.035,.024,.008],6,3)
        for twig in range(3):
            turn=angle+(twig-1)*.67
            direction=Vector((math.cos(turn),math.sin(turn),rng.uniform(.12,.45))).normalized()
            start=branch_base.lerp(end,.40+twig*.24)
            shoot_length=rng.uniform(.52,.78)
            finish=start+direction*shoot_length
            tube(wood,[start,start.lerp(finish,.6)+Vector((0,0,.05)),finish],[.012,.007,.0015],5,2)
            side=Vector((-direction.y,direction.x,0)).normalized()
            tint=rng.choice([(0.66,.79,.65),(.88,.96,.76),(.68,.88,.80),(.91,.94,.77),(1,1,.90)])
            for pair in range(5):
                t=.12+pair*.17
                for sign in [-1,1]:
                    origin=start.lerp(finish,t+(.025 if sign==1 else 0))+Vector((0,0,.035*math.sin(math.pi*t)))
                    leaf_dir=(side*sign*.88+direction*.55+Vector((0,0,rng.uniform(-.1,.5)))).normalized()
                    length=rng.uniform(.29,.43)*(1-.26*t)
                    leaf(leaves,origin,leaf_dir,length,length*rng.uniform(.22,.31),tint)
                    leaf_count+=1
            leaf(leaves,finish-direction*.04,direction+Vector((0,0,.2)),.29,.075,tint)
            leaf_count+=1

# Three small succulent rosettes with ochre-orange flower sprays at the roots.
for clump,(center,size) in enumerate([(Vector((-.7,-.65,.03)),.9),(Vector((.35,-.90,.03)),.72),(Vector((.85,.3,.03)),.6)]):
    for i in range(13):
        angle=i*2.39996+clump
        elevation=.3 if i<8 else .85
        direction=Vector((math.cos(angle),math.sin(angle),elevation))
        leaf(succulents,center,direction,rng.uniform(.40,.68)*size,.07*size,(1,1,1),.25,.15)
    for i in range(3):
        angle=i*2.1+clump
        start=center+Vector((math.cos(angle)*.07,math.sin(angle)*.07,0))
        tip=start+Vector((math.cos(angle)*.17,math.sin(angle)*.17,rng.uniform(.65,.95)*size))
        tube(stems,[start,start.lerp(tip,.5),tip],[.016,.012,.004],6,3)
        for j in range(4):
            origin=start.lerp(tip,.60+j*.10)
            angle2=angle+j*2.3
            forward=Vector((math.cos(angle2)*.6,math.sin(angle2)*.6,.45)).normalized()
            flower_center=origin+forward*.08
            tube(stems,[origin,flower_center],[.007,.004],5,2)
            right=forward.cross(Vector((0,0,1))).normalized(); up=right.cross(forward).normalized()
            for k in range(5):
                a=k*math.tau/5
                d=(right*math.cos(a)+up*math.sin(a))*.6+forward*.7
                leaf(petals,flower_center,d,.085*size,.032*size,(rng.uniform(.85,1),rng.uniform(.8,1),.85),.45,.05)
            tube(hearts,[flower_center,flower_center+forward*.05],[.018,.012],7,2)

bark=material('Weathered grey-brown bark',(.16,.105,.065))
bn=bark.node_tree.nodes; bl=bark.node_tree.links; bp=bn.get('Principled BSDF')
coord=bn.new('ShaderNodeUVMap'); coord.uv_map='BarkSource'
bark_source=bpy.data.images.load(str(SOURCE/'bark_basecolor_source.png'))
bark_texture=bn.new('ShaderNodeTexImage'); bark_texture.image=bark_source
bl.new(coord.outputs['UV'],bark_texture.inputs['Vector'])
bl.new(bark_texture.outputs['Color'],bp.inputs['Base Color'])
bark_height=bn.new('ShaderNodeRGBToBW'); bl.new(bark_texture.outputs['Color'],bark_height.inputs[0])
bump=bn.new('ShaderNodeBump'); bump.inputs['Strength'].default_value=.48; bump.inputs['Distance'].default_value=.045
bl.new(bark_height.outputs[0],bump.inputs['Height']); bl.new(bump.outputs[0],bp.inputs['Normal'])
bark_obj=wood.make('Twisted trunk and branches',bark)
bark_obj.data.uv_layers.active.name='BarkSource'
bark_obj.data.uv_layers.new(name='UVMap')
bark_obj.data.uv_layers.active=bark_obj.data.uv_layers['UVMap']
bark_obj.data.uv_layers['UVMap'].active_render=True

# Generated botanical source uses a central vein aligned to every leaf's fold.
leaf_mat=material('Sage canopy',(.12,.28,.14),.66); leaf_mat.use_backface_culling=False
ln=leaf_mat.node_tree.nodes; ll=leaf_mat.node_tree.links; lp=ln.get('Principled BSDF')
leaf_source=bpy.data.images.load(str(SOURCE/'leaf_basecolor_source.png'))
leaf_texture=ln.new('ShaderNodeTexImage'); leaf_texture.image=leaf_source
ll.new(leaf_texture.outputs['Color'],lp.inputs['Base Color'])
leaf_height=ln.new('ShaderNodeRGBToBW'); ll.new(leaf_texture.outputs['Color'],leaf_height.inputs[0])
leaf_bump=ln.new('ShaderNodeBump'); leaf_bump.inputs['Strength'].default_value=.25; leaf_bump.inputs['Distance'].default_value=.006
ll.new(leaf_height.outputs[0],leaf_bump.inputs['Height']); ll.new(leaf_bump.outputs[0],lp.inputs['Normal'])

def bake(obj,mat,name,kind='DIFFUSE',size=1024):
    bpy.ops.object.select_all(action='DESELECT'); obj.select_set(True); bpy.context.view_layer.objects.active=obj
    n=mat.node_tree.nodes; link=mat.node_tree.links; p=n.get('Principled BSDF'); output=n.get('Material Output')
    img=bpy.data.images.new(name,width=size,height=size,alpha=False)
    if kind=='NORMAL': img.colorspace_settings.name='Non-Color'
    target=n.new('ShaderNodeTexImage'); target.image=img; n.active=target
    if kind=='DIFFUSE':
        emission=n.new('ShaderNodeEmission')
        link.new(p.inputs['Base Color'].links[0].from_socket,emission.inputs['Color']); link.new(emission.outputs[0],output.inputs['Surface'])
    bpy.ops.object.bake(type='EMIT' if kind=='DIFFUSE' else kind,margin=12)
    link.new(p.outputs[0],output.inputs['Surface'])
    img.filepath_raw=str(OUT/(name+'.png')); img.file_format='PNG'; img.save()
    print('BAKED '+name,flush=True)
    return img

# Source bark follows curved branches; bake target is a separate unique UV atlas.
bpy.ops.object.select_all(action='DESELECT'); bark_obj.select_set(True); bpy.context.view_layer.objects.active=bark_obj
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT'); bpy.ops.uv.smart_project(angle_limit=1.0,island_margin=.012); bpy.ops.object.mode_set(mode='OBJECT')
bark_color=bake(bark_obj,bark,'tree_bark_albedo',size=2048)
bark_normal=bake(bark_obj,bark,'tree_bark_normal','NORMAL',size=2048)
# Export only the baked UVs so glTF binds the intended map to TEXCOORD_0.
bark_obj.data.uv_layers.remove(bark_obj.data.uv_layers['BarkSource'])
bpy.ops.mesh.primitive_plane_add(); sample=bpy.context.object; sample.name='Leaf texture bake surface'; sample.data.materials.append(leaf_mat)
leaf_color=bake(sample,leaf_mat,'tree_leaf_albedo',size=1024)
leaf_normal=bake(sample,leaf_mat,'tree_leaf_normal','NORMAL',size=1024)
# The same organic source gives the blue-green rosettes coherent vein detail.
succulent_source=leaf_mat.copy(); sn=succulent_source.node_tree.nodes; sl=succulent_source.node_tree.links
sp=sn.get('Principled BSDF'); hue=sn.new('ShaderNodeHueSaturation')
hue.inputs['Hue'].default_value=.62; hue.inputs['Saturation'].default_value=.65; hue.inputs['Value'].default_value=1.15
sl.new(sp.inputs['Base Color'].links[0].from_socket,hue.inputs['Color']); sl.new(hue.outputs[0],sp.inputs['Base Color'])
sample.data.materials.clear(); sample.data.materials.append(succulent_source)
succulent_color=bake(sample,succulent_source,'rosette_albedo',size=512)
bpy.data.objects.remove(sample,do_unlink=True)

def texture_material(name,color_image,normal_image=None,tinted=False,roughness=.8):
    m=material(name,(1,1,1),roughness); n=m.node_tree.nodes; l=m.node_tree.links; p=n.get('Principled BSDF')
    img=n.new('ShaderNodeTexImage'); img.image=color_image
    if tinted:
        # glTF multiplies COLOR_0 into base color; export Tint explicitly below.
        vc=n.new('ShaderNodeVertexColor'); vc.layer_name='Tint'
        mult=n.new('ShaderNodeMixRGB'); mult.blend_type='MULTIPLY'; mult.inputs[0].default_value=1
        l.new(img.outputs['Color'],mult.inputs[1]); l.new(vc.outputs['Color'],mult.inputs[2]); l.new(mult.outputs[0],p.inputs['Base Color'])
        m.use_backface_culling=False
    else: l.new(img.outputs['Color'],p.inputs['Base Color'])
    if normal_image:
        tex=n.new('ShaderNodeTexImage'); tex.image=normal_image
        norm=n.new('ShaderNodeNormalMap'); l.new(tex.outputs[0],norm.inputs['Color']); l.new(norm.outputs[0],p.inputs['Normal'])
    return m

bark_obj.data.materials.clear(); bark_obj.data.materials.append(texture_material('Bark PBR',bark_color,bark_normal))
leaf_obj=leaves.make('Layered sage canopy',texture_material('Sage leaf PBR',leaf_color,leaf_normal,tinted=True,roughness=.72))
succulent_mat=texture_material('Blue-green rosettes',succulent_color,leaf_normal,roughness=.65); succulent_mat.use_backface_culling=False
petal_mat=material('Ochre coral flower petals',(.85,.30,.055),.6); petal_mat.use_backface_culling=False
succulents.make('Root rosettes',succulent_mat)
petals.make('Small golden flowers',petal_mat)
stems.make('Flower stems',material('Flower stems',(.15,.21,.07)))
hearts.make('Flower pollen',material('Golden pollen',(.95,.62,.17),.65))

for obj in scene.objects:
    if obj.type=='MESH':
        obj.select_set(True)
        bpy.context.view_layer.objects.active=obj
        triangulate=obj.modifiers.new('Portable triangle topology','TRIANGULATE')
        bpy.ops.object.modifier_apply(modifier=triangulate.name)
for img in [bark_source,leaf_source,bark_color,bark_normal,leaf_color,leaf_normal,succulent_color]: img.pack()
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'tree_authoring_v2.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'desert_tree.glb'),export_format='GLB',use_selection=True,export_tangents=True,export_vertex_color='NAME',export_vertex_color_name='Tint',export_animations=False,export_cameras=False,export_lights=False)
triangles=0
for obj in scene.objects:
    if obj.type=='MESH': obj.data.calc_loop_triangles(); triangles+=len(obj.data.loop_triangles)
(OUT/'asset_info.json').write_text(json.dumps({'blender':bpy.app.version_string,'revision':2,'triangles':triangles,'canopy_leaves':leaf_count,'materials':6,'source':'art_source/tree/tree_authoring_v2.blend','license_note':'Original mesh; generated bark and leaf surface sources. See TEXTURE_SOURCES.md.'},indent=2)+'\n')
print('TREE COMPLETE',triangles,'triangles;',leaf_count,'leaves',flush=True)
