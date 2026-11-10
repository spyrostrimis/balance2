"""Original sanctuary gate. Blender --background --factory-startup --python this_file.
Blender Z up, facade faces -Y; exported Godot facade faces +Z. Units are metres.
Rebuild overwrites Gate study outputs only. No third-party geometry/add-ons.
"""
import bpy, bmesh, math, random, json
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[3]
SRC = Path(__file__).resolve().parent
OUT = ROOT / 'assets/gate_study/v2'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version = 0
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 8
rng = random.Random(709)
groups = {k: [] for k in ('stone','door','cloth','bronze','ivy','stem','grass')}

def mesh(name, verts, faces, group='stone', bevel=.035):
    data = bpy.data.meshes.new(name)
    data.from_pydata(verts, [], faces); data.update()
    obj = bpy.data.objects.new(name, data); scene.collection.objects.link(obj)
    bpy.context.view_layer.objects.active = obj; obj.select_set(True)
    bm = bmesh.new(); bm.from_mesh(data)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces)); bm.to_mesh(data); bm.free()
    if bevel:
        mod = obj.modifiers.new('Worn arris', 'BEVEL'); mod.width = bevel; mod.segments = 3
        bpy.ops.object.modifier_apply(modifier=mod.name)
        for p in data.polygons: p.use_smooth = True
        mod = obj.modifiers.new('Broad stone face normals', 'WEIGHTED_NORMAL'); mod.keep_sharp = True
        bpy.ops.object.modifier_apply(modifier=mod.name)
    groups[group].append(obj); obj.select_set(False)
    return obj

def prism(name, outline, front, back, group='stone', bevel=.035):
    n = len(outline)
    verts = [(x,y,z) for y in (front,back) for x,z in outline]
    faces = [tuple(range(n-1,-1,-1)), tuple(range(n,2*n))]
    faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    return mesh(name, verts, faces, group, bevel)

def block(name, x, y, z, w, d, h, group='stone', chip=.06):
    # Clipped corners form physical wear, distinct from the material's fine cracks.
    c = min(chip,w*.15,h*.15)
    outline = [(x-w/2+c,z-h/2),(x+w/2-c*.3,z-h/2),(x+w/2,z-h/2+c),
               (x+w/2,z+h/2-c*1.6),(x+w/2-c,z+h/2),(x-w/2+c*.5,z+h/2),
               (x-w/2,z+h/2-c),(x-w/2,z-h/2+c*.7)]
    return prism(name,outline,y-d/2,y+d/2,group,min(.035,w*.1,h*.1))

def ribbon(name, path, width, front, depth, group='stone', joints=1, bevel=.025):
    # A curved architectural band constructed as fitted voussoirs, not rotated boxes.
    for start in range(0,len(path)-1,joints):
        stop = min(start+joints,len(path)-1)
        left=[]; right=[]
        for i in range(start,stop+1):
            p=Vector(path[i]); a=Vector(path[max(0,i-1)]); b=Vector(path[min(len(path)-1,i+1)])
            tangent=(b-a).normalized(); normal=Vector((-tangent.y,tangent.x))
            if i==start and start>0: p += tangent*.013
            if i==stop and stop<len(path)-1: p -= tangent*.013
            left.append(tuple(p+normal*width/2)); right.append(tuple(p-normal*width/2))
        # Explicit strip quads preserve the narrow open interior at bends.
        # A concave ngon plus bevel can create a large folded triangle here.
        outline=left+right[::-1]; k=len(left); n=len(outline)
        verts=[(x,y,z) for y in (front,front+depth) for x,z in outline]
        faces=[]
        for i in range(k-1):
            a=i; b=i+1; c=n-2-i; d=n-1-i
            faces.append((d,c,b,a)); faces.append((a+n,b+n,c+n,d+n))
        faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
        mesh(name+' %02d'%start,verts,faces,group,bevel)

def bezier(a,b,c,d,n=28):
    return [tuple((1-t)**3*Vector(a)+3*(1-t)**2*t*Vector(b)+3*(1-t)*t*t*Vector(c)+t**3*Vector(d)) for t in [i/n for i in range(n+1)]]

def arch_path(width,spring,apex,base=1.36):
    left=[(-width,base),(-width,2.25),(-width,3.25),(-width,spring)]
    left+=bezier((-width,spring),(-width,spring+.7),(-width*.6,apex-.5),(0,apex),16)[1:]
    return left+[(-x,z) for x,z in left[-2::-1]]

def tube(name, points, radius, group='stem', sides=7):
    verts=[]; faces=[]
    for i,p in enumerate(points):
        p=Vector(p); tangent=(Vector(points[min(i+1,len(points)-1)])-Vector(points[max(i-1,0)])).normalized()
        guide=Vector((0,1,0)) if abs(tangent.y)<.9 else Vector((1,0,0))
        u=tangent.cross(guide).normalized(); v=tangent.cross(u).normalized()
        for j in range(sides):
            a=j*math.tau/sides; verts.append(tuple(p+radius*(u*math.cos(a)+v*math.sin(a))))
    for i in range(len(points)-1):
        for j in range(sides):
            a=i*sides+j; b=i*sides+(j+1)%sides
            faces.append((a,b,b+sides,a+sides))
    faces.extend([tuple(range(sides-1,-1,-1)),tuple((len(points)-1)*sides+j for j in range(sides))])
    obj=mesh(name,verts,faces,group,0)
    for p in obj.data.polygons: p.use_smooth=True
    return obj

def course(name,x,y,z,w,d,h,chip=.09):
    obj=block(name,x,y,z,w,d,h,chip=chip)
    return obj

def pillar(x,height,front=-1.0,side_ruin=False):
    # Cross-section built from an octagonal core, projecting flutes and collars.
    w=.69 if side_ruin else .49
    for row in range(6):
        z=.50+(height-1.15)*(row+.5)/6
        course('Jointed pier core',x,front+.22,z,w,.68,(height-1.15)/6-.025)
    for dx in (-w*.35,0,w*.35):
        tube('Carved pier flute',[(x+dx,front-.17,.68),(x+dx,front-.17,height-.55)],.085 if side_ruin else .068,'stone',10)
    for z,ww,dd,hh in [(.13,w+.52,1.0,.26),(.34,w+.35,.87,.17),(.51,w+.19,.76,.17),
                         (height-.55,w+.19,.82,.16),(height-.34,w+.34,.94,.23),(height-.13,w+.52,1.12,.19)]:
        course('Moulded pier base and capital',x,front+.12,z,ww,dd,hh,.045)
    for dx in (-.23,.23):
        prism('Capital carved leaf',[(x+dx-.095,height-.50),(x+dx-.05,height-.25),(x+dx,height-.18),
                                     (x+dx+.09,height-.33),(x+dx+.10,height-.50)],front-.46,front-.34,bevel=.018)

# Six broad steps. Individual slabs have clipped and uneven worn noses.
for step in range(6):
    top=.23*(step+1); front=-4.90+step*.58; width=7.2-step*.11
    cuts=5+step%2; widths=[rng.uniform(.85,1.18) for _ in range(cuts)]
    widths=[v*width/sum(widths) for v in widths]; x=-width/2
    for j,w in enumerate(widths):
        course('Worn stair tread',x+w/2,front+.29,top/2,w-.028,.64,top,chip=rng.uniform(.07,.17))
        x+=w
for row in range(3):
    for col in range(5):
        course('Threshold paving',(col-2)*1.16,-1.08+row*.7,.67,1.14,.68,1.34,.07)

# Compact central facade. Its crown is cut stone, rather than a tall spear.
for side in (-1,1):
    for row in range(7):
        z=.18+row*.77; h=.74
        for col in range(3):
            x=side*(2.25+col*.96)
            course('Main wall ashlar',x,.68,z+h/2,.94,1.85,h,.06+rng.random()*.07)
    # Raised wall framing behind each banner, with stepped cornices.
    for z,h,depth in [(1.2,.18,.46),(5.4,.22,.45),(5.65,.16,.56)]:
        course('Panel cornice',side*3.96,-.36,z,2.34,depth,h,.04)
    for x in (3.05,4.92):
        pillar(side*x,6.18 if x>4 else 6.65,front=-.89,side_ruin=False)
    # Sloping fragmented pediment with hand-cut perimeter.
    profile=[(side*.12,5.48),(side*2.63,5.42),(side*2.72,6.25),
             (side*2.14,6.55),(side*1.79,6.82),(side*1.68,7.25),
             (side*1.22,7.25),(side*.98,7.72),(side*.48,7.85),(side*.18,7.55)]
    prism('Broken crown masonry',profile,-.24,.80,bevel=.055)
    path=[(side*.46,7.70),(side*1.24,7.10),(side*1.97,6.60),(side*2.70,6.20)]
    ribbon('Pediment carved sweep',path,.22,-.61,.42,joints=1,bevel=.025)

def round_arch(width,spring,base=1.39):
    pts=[(-width,base),(-width,2.2),(-width,3.0),(-width,spring)]
    pts += [(width*math.cos(math.pi-i*math.pi/32),spring+width*.83*math.sin(math.pi-i*math.pi/32)) for i in range(1,33)]
    pts += [(width,3.0),(width,2.2),(width,base)]
    return pts

# Four rounded archivolts. Alternating deep fillets and rounded reeds catch light.
for tier in range(4):
    w=1.54+tier*.245
    path=round_arch(w,3.95)
    ribbon('Fitted arch voussoirs',path,.20,-1.02+tier*.075,.76,joints=2,bevel=.035)
    tube('Rounded archivolt moulding',[(x,-1.055+tier*.075,z) for x,z in path],.048,'stone',8)
for side in (-1,1):
    for dx in (1.58,1.84,2.08,2.32):
        course('Arch foot collar',side*dx,-.87,1.48,.29,.92,.19,.025)
        course('Arch impost collar',side*dx,-.84,3.93,.31,.97,.18,.025)

# Deep dark sealed recess. No luminous seam in the new reference.
outline=[(-1.53,1.32),(1.53,1.32),(1.53,3.95)]
outline += [(1.53*math.cos(i*math.pi/24),3.95+1.53*.83*math.sin(i*math.pi/24)) for i in range(1,25)]
prism('Dark recessed sealed portal',outline,-.12,.20,'door',.035)
for side in (-1,1):
    ribbon('Subtle sealed leaf edge',[(side*.022,1.4),(side*.022,5.15)],.016,-.15,.02,'bronze',joints=2,bevel=.003)
    ribbon('Recess panel carving',[(side*.2,1.61),(side*1.22,1.61),(side*1.22,3.91),(side*.88,4.55)],.034,-.19,.045,'door',joints=4,bevel=.01)

seal_z=6.47
circle=[(math.sin(i*math.tau/80)*.83,seal_z+math.cos(i*math.tau/80)*.69) for i in range(81)]
prism('Recessed circular seal field',[(x*.91,seal_z+(z-seal_z)*.91) for x,z in circle[:-1]],-.43,-.24,'door',.025)
ribbon('Carved seal perimeter',circle,.17,-.68,.30,joints=5,bevel=.028)
tube('Seal inner bead',[(x*.80,-.70,seal_z+(z-seal_z)*.80) for x,z in circle],.027,'stone',8)
for a in range(12):
    theta=a*math.tau/12
    ribbon('Seal radial cuts',[(math.sin(theta)*.77,seal_z+math.cos(theta)*.64),(math.sin(theta)*.88,seal_z+math.cos(theta)*.73)],.022,-.718,.024,'door',joints=2,bevel=.003)
prism('Short axial crown blade',[(-.11,5.56),(.11,5.56),(.14,7.65),(.04,7.99),(-.10,7.78)],-.93,-.41,bevel=.025)
ribbon('Axial incised line',[(0,5.7),(0,7.76)],.022,-.96,.02,'bronze',joints=2,bevel=.003)

# Broken horizontal side porticoes flank the gate, like the uploaded reference.
for side in (-1,1):
    inner=side*5.25; outer=side*8.2
    pillar(outer,6.12 if side<0 else 5.9,front=-.47,side_ruin=True)
    pillar(inner,5.98,front=-.35,side_ruin=True)
    center=side*6.77
    for z,w,h,d in [(5.70,3.58,.24,1.25),(5.92,3.85,.16,1.38),(6.12,3.62,.24,1.21),(6.34,3.94,.18,1.43)]:
        # A lost end and uneven top cap make the two ruins subtly asymmetric.
        if side>0: z-=.18
        course('Broken portico entablature',center,.10,z,w,d,h,.07)
    course('Portico frieze inset',center,-.56,5.70 if side<0 else 5.52,3.10,.055,.20,.015)
    for j in range(12):
        x=center-1.43+j*.26; z=5.71 if side<0 else 5.53
        ribbon('Carved repeating frieze',[(x-.10,z),(x,z+.07),(x+.10,z),(x,z-.07),(x-.10,z)],.023,-.61,.045,joints=4,bevel=.006)
    for j in range(4):
        course('Cornice dentil',center-1.20+j*.80,-.58,5.48 if side<0 else 5.30,.24,.26,.18,.025)
    # A few battered base-wall stones leave a recess under the lintel.
    for j in range(3):
        course('Broken portico footing',side*(5.7+j*.92),.33,.29,.88,1.6,.56,.14)

# Two modest, narrow palatinate banners, supported by metal rods and brackets.
for side in (-1,1):
    cx=side*3.88; top=5.22; width=.74; height=1.88; nx=12; nz=24
    verts=[]; faces=[]; uvs=[]
    for j in range(nz+1):
        t=j/nz
        for i in range(nx+1):
            u=i/nx
            verts.append((cx+(u-.5)*width+.022*math.sin(t*4)*t,
                          -.71-.042*math.sin(u*math.pi*5+t)*(.2+.8*t)-.06*math.sin(t*3),
                          top-t*height+.16*(1-abs(2*u-1))*t**10))
            uvs.append((u,1-t))
    for j in range(nz):
        for i in range(nx):
            k=j*(nx+1)+i; faces.append((k,k+1,k+nx+2,k+nx+1))
    obj=mesh('Weathered hanging purple cloth',verts,faces,'cloth',0)
    uv=obj.data.uv_layers.new(name='UVMap')
    for poly in obj.data.polygons:
        poly.use_smooth=True
        for loop in poly.loop_indices: uv.data[loop].uv=uvs[obj.data.loops[loop].vertex_index]
    tube('Banner crossbar',[(cx-.46,-.71,top+.035),(cx+.46,-.71,top+.035)],.035,'bronze')
    for dx in (-.39,.39): tube('Banner bracket',[(cx+dx,-.27,top+.035),(cx+dx,-.71,top+.035)],.025,'bronze')

# Ivy: each card is rooted at UV (0.5, 0.03), where the generated petiole ends.
leaf_verts=[]; leaf_faces=[]; leaf_uv=[]
def leaf(base, direction, length, angle):
    base=Vector(base); up=Vector(direction).normalized()
    across=Vector((up.z,0,-up.x)).normalized()
    across=(across*math.cos(angle)+Vector((0,1,0))*math.sin(angle)).normalized()
    normal=across.cross(up).normalized()
    start=len(leaf_verts)
    for j in range(5):
        v=j/4
        for i in range(3):
            u=i/2
            p=base+up*((v-.03)*length)+across*((u-.5)*length*.95)+normal*(math.sin(v*math.pi)*.04+abs(u-.5)*.04)
            leaf_verts.append(tuple(p)); leaf_uv.append((u,v))
    for j in range(4):
        for i in range(2):
            k=start+j*3+i; leaf_faces.append((k,k+1,k+4,k+3))

for side in (-1,1):
    for vine in range(3):
        # Climbers follow front stone surfaces, then drape over the entablature.
        anchor=side*(7.9 if vine==0 else 5.5 if vine==1 else 7.35)
        top=6.30 if side<0 else 6.12
        bottom=.20 if vine<2 else 2.3
        points=[]
        for j in range(51):
            t=j/50; z=bottom+(top-bottom)*t
            x=anchor+.22*math.sin(t*9+vine)+.11*math.sin(t*21+side)
            y=-1.04-.10*math.sin(t*12+vine)
            points.append((x,y,z))
        tube('Rooted climbing ivy main stem',points,.025,'stem')
        for j in range(2,49):
            p=Vector(points[j]); alternating=(-1 if j%2 else 1)
            for k in range(2 if j%3 else 3):
                direction=Vector((alternating*rng.uniform(.45,.85),rng.uniform(-.35,-.1),rng.uniform(.2,.85))).normalized()
                end=p+direction*rng.uniform(.09,.22)
                tube('Connected ivy petiole',[tuple(p),tuple(end)],.007,'stem',5)
                leaf(end,direction,rng.uniform(.22,.39),rng.uniform(-.75,.75))
            if j%6==0:
                end=p+Vector((alternating*.47,-.08,-.30))
                tube('Ivy lateral branch',[tuple(p),tuple(p.lerp(end,.5)+Vector((0,-.05,.1))),tuple(end)],.012,'stem',5)
                for q in (.4,.7,1.0):
                    leaf(p.lerp(end,q),Vector((alternating*.55,-.25,.5)),rng.uniform(.22,.32),rng.uniform(-.6,.6))
obj=mesh('Attached ivy leaves',leaf_verts,leaf_faces,'ivy',0)
uv=obj.data.uv_layers.new(name='UVMap')
for poly in obj.data.polygons:
    poly.use_smooth=True
    for loop in poly.loop_indices: uv.data[loop].uv=leaf_uv[obj.data.loops[loop].vertex_index]

# Rubble and sparse dry tufts concentrate at the wall bases, leaving stairs clear.
for side in (-1,1):
    for i in range(20):
        x=side*rng.uniform(3.9,8.8); y=rng.uniform(-2.4,1.1); w=rng.uniform(.16,.48); h=rng.uniform(.10,.33)
        obj=course('Fallen worked stone',x,y,h*.46,w,w*.75,h,w*.24)
        obj.rotation_euler.z=rng.uniform(-.8,.8)
    for i in range(21):
        base=Vector((side*rng.uniform(4.1,8.7),rng.uniform(-2.2,-.85),.01))
        for blade in range(9):
            a=rng.random()*math.tau; h=rng.uniform(.15,.60); w=rng.uniform(.018,.045)
            direction=Vector((math.cos(a),math.sin(a),0)); across=Vector((-math.sin(a),math.cos(a),0))*w
            root=base+direction*rng.uniform(0,.10); tip=root+direction*h*.6+Vector((0,0,h)); mid=root.lerp(tip,.55)+Vector((0,0,h*.15))
            mesh('Dry grass blade',[tuple(root-across),tuple(root+across),tuple(mid+across*.5),tuple(tip),tuple(mid-across*.5)],[(0,1,2,3,4)],'grass',0)

# Per-block age variation is stored before joining; fine texture is generated art.
for obj in groups['stone']:
    attr=obj.data.color_attributes.new(name='StoneAge',type='FLOAT_COLOR',domain='CORNER')
    v=rng.uniform(.76,1.02)
    for c in attr.data: c.color=(v,v*.99,v*.94,1)

def join_group(name):
    bpy.ops.object.select_all(action='DESELECT')
    for obj in groups[name]: obj.select_set(True)
    bpy.context.view_layer.objects.active=groups[name][0]
    if len(groups[name])>1: bpy.ops.object.join()
    obj=bpy.context.object; obj.name='Sanctuary II '+name
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    # Bake and export the identical triangulation, especially for large portal
    # ngons. Late triangulation can change tangent interpolation across a face.
    tri=obj.modifiers.new('Stable bake triangles','TRIANGULATE')
    bpy.ops.object.modifier_apply(modifier=tri.name)
    if name not in ('cloth','ivy'):
        bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
        bpy.ops.uv.smart_project(angle_limit=1.05,island_margin=.003)
        bpy.ops.object.mode_set(mode='OBJECT')
    return obj

assets={name:join_group(name) for name in groups}
source_images={key:bpy.data.images.load(str(file)) for key,file in [('stone',SRC/'aged_limestone_source.png'),('cloth',SRC.parent/'banner_basecolor_source.png'),('ivy',SRC/'ivy_leaf_source.png')]}
for img in source_images.values(): img.pack()
authoring={}
for name,obj in assets.items():
    mat=bpy.data.materials.new('Gate II '+name+' authoring'); mat.use_nodes=True
    obj.data.materials.clear(); obj.data.materials.append(mat)
    ns=mat.node_tree.nodes; ls=mat.node_tree.links; p=ns.get('Principled BSDF'); out=ns.get('Material Output')
    p.inputs['Roughness'].default_value=.85
    if name in ('stone','door','cloth','ivy'):
        tex=ns.new('ShaderNodeTexImage'); tex.image=source_images[name if name in ('cloth','ivy') else 'stone']
        if name in ('stone','door'):
            coord=ns.new('ShaderNodeTexCoord'); scale=ns.new('ShaderNodeVectorMath'); scale.operation='SCALE'; scale.inputs['Scale'].default_value=.41
            ls.new(coord.outputs['Object'],scale.inputs[0]); ls.new(scale.outputs[0],tex.inputs[0]); tex.projection='BOX'; tex.projection_blend=.18
        tint=ns.new('ShaderNodeMixRGB'); tint.blend_type='MULTIPLY'; tint.inputs[0].default_value=1
        tint.inputs[2].default_value={'stone':(.79,.85,.91,1),'door':(.055,.065,.072,1),'cloth':(.60,.48,.52,1),'ivy':(.77,.86,.63,1)}[name]
        ls.new(tex.outputs['Color'],tint.inputs[1]); color=tint.outputs[0]
        if name=='stone':
            attr=ns.new('ShaderNodeAttribute'); attr.attribute_name='StoneAge'
            age=ns.new('ShaderNodeMixRGB'); age.blend_type='MULTIPLY'; age.inputs[0].default_value=1
            ls.new(color,age.inputs[1]); ls.new(attr.outputs['Color'],age.inputs[2]); color=age.outputs[0]
            ao=ns.new('ShaderNodeAmbientOcclusion'); ao.inputs['Distance'].default_value=.48; ao.samples=16
            soften=ns.new('ShaderNodeMapRange'); soften.inputs['To Min'].default_value=.55; soften.inputs['To Max'].default_value=1.0
            ls.new(ao.outputs['AO'],soften.inputs[0])
            age=ns.new('ShaderNodeMixRGB'); age.blend_type='MULTIPLY'; age.inputs[0].default_value=1
            ls.new(color,age.inputs[1]); ls.new(soften.outputs[0],age.inputs[2]); color=age.outputs[0]
        ls.new(color,p.inputs['Base Color'])
        gray=ns.new('ShaderNodeRGBToBW'); ls.new(tex.outputs[0],gray.inputs[0])
        bump=ns.new('ShaderNodeBump'); bump.inputs['Strength'].default_value=.38 if name=='stone' else .22
        bump.inputs['Distance'].default_value=.06 if name=='stone' else .012
        ls.new(gray.outputs[0],bump.inputs['Height']); ls.new(bump.outputs[0],p.inputs['Normal'])
        rough=ns.new('ShaderNodeMapRange'); rough.inputs['To Min'].default_value=.78; rough.inputs['To Max'].default_value=.95
        ls.new(gray.outputs[0],rough.inputs[0]); ls.new(rough.outputs[0],p.inputs['Roughness'])
        if name=='ivy':
            ls.new(tex.outputs['Alpha'],p.inputs['Alpha']); mat.surface_render_method='DITHERED'; mat.alpha_threshold=.45; mat.use_backface_culling=False
            # glTF exporter interprets this as MASK and keeps the portable source PNG.
            mat['gltf_alpha_mode']='MASK'
        else: authoring[name]=(mat,color,rough.outputs[0])
    elif name=='bronze':
        p.inputs['Base Color'].default_value=(.13,.095,.045,1); p.inputs['Metallic'].default_value=.55; p.inputs['Roughness'].default_value=.66
    elif name=='stem': p.inputs['Base Color'].default_value=(.065,.085,.026,1)
    elif name=='grass': p.inputs['Base Color'].default_value=(.24,.19,.075,1); mat.use_backface_culling=False

bpy.ops.wm.save_as_mainfile(filepath=str(SRC/'gate_authoring_v2.blend'))
for name,(mat,color,roughness) in authoring.items():
    obj=assets[name]; bpy.ops.object.select_all(action='DESELECT'); obj.select_set(True); bpy.context.view_layer.objects.active=obj
    ns=mat.node_tree.nodes; ls=mat.node_tree.links; p=ns.get('Principled BSDF'); out=ns.get('Material Output')
    target=ns.new('ShaderNodeTexImage'); emit=ns.new('ShaderNodeEmission')
    resolution=4096 if name=='stone' else 1024
    maps={}
    for channel,socket in [('albedo',color),('normal',None),('roughness',roughness)]:
        img=bpy.data.images.new('gate2_'+name+'_'+channel,width=resolution,height=resolution,alpha=False)
        if channel!='albedo': img.colorspace_settings.name='Non-Color'
        target.image=img; ns.active=target
        if channel=='normal': ls.new(p.outputs[0],out.inputs[0])
        else: ls.new(socket,emit.inputs['Color']); ls.new(emit.outputs[0],out.inputs[0])
        bpy.ops.object.bake(type='NORMAL' if channel=='normal' else 'EMIT',margin=12,normal_space='TANGENT')
        img.filepath_raw=str(OUT/(img.name+'.png')); img.file_format='PNG'; img.save(); maps[channel]=img
        print('BAKED',img.name,flush=True)
    portable=bpy.data.materials.new('Gate II '+name+' PBR'); portable.use_nodes=True
    pn=portable.node_tree.nodes; pl=portable.node_tree.links; pb=pn.get('Principled BSDF')
    for channel,img in maps.items():
        t=pn.new('ShaderNodeTexImage'); t.image=img
        if channel=='normal':
            norm=pn.new('ShaderNodeNormalMap'); pl.new(t.outputs[0],norm.inputs['Color']); pl.new(norm.outputs[0],pb.inputs['Normal'])
        else: pl.new(t.outputs[0],pb.inputs['Base Color' if channel=='albedo' else 'Roughness'])
    if name=='cloth': portable.use_backface_culling=False
    obj.data.materials.clear(); obj.data.materials.append(portable)

# Replace ivy authoring nodes with portable texture PBR (no engine procedural nodes).
obj=assets['ivy']; mat=bpy.data.materials.new('Ivy cutout PBR'); mat.use_nodes=True
ns=mat.node_tree.nodes; ls=mat.node_tree.links; p=ns.get('Principled BSDF')
tex=ns.new('ShaderNodeTexImage'); tex.image=source_images['ivy']
ls.new(tex.outputs['Color'],p.inputs['Base Color']); ls.new(tex.outputs['Alpha'],p.inputs['Alpha'])
p.inputs['Roughness'].default_value=.82
mat.surface_render_method='DITHERED'; mat.alpha_threshold=.45; mat.use_backface_culling=False
obj.data.materials.clear(); obj.data.materials.append(mat)

bpy.ops.object.select_all(action='SELECT'); triangles=0
for obj in assets.values():
    bpy.context.view_layer.objects.active=obj
    mod=obj.modifiers.new('Portable triangles','TRIANGULATE'); bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.data.calc_loop_triangles(); triangles+=len(obj.data.loop_triangles)
bpy.ops.export_scene.gltf(filepath=str(OUT/'sanctuary_gate.glb'),export_format='GLB',use_selection=True,export_tangents=True,export_animations=False,export_cameras=False,export_lights=False)
# Blender 5's DITHERED surface exports BLEND. Declare cutout semantics explicitly
# in portable glTF so overlapping ivy leaves have stable depth and shadows.
import struct
glb_path=OUT/'sanctuary_gate.glb'
data=glb_path.read_bytes(); old_length=struct.unpack_from('<I',data,12)[0]
gltf=json.loads(data[20:20+old_length])
for material in gltf['materials']:
    if material['name']=='Ivy cutout PBR':
        material['alphaMode']='MASK'; material['alphaCutoff']=.45
encoded=json.dumps(gltf,separators=(',',':')).encode('utf-8')
encoded+=b' '*((-len(encoded))%4)
tail=data[20+old_length:]
glb_path.write_bytes(struct.pack('<III',0x46546c67,2,20+len(encoded)+len(tail))+struct.pack('<II',len(encoded),0x4e4f534a)+encoded+tail)
stats={'revision':2,'blender':bpy.app.version_string,'triangles':triangles,'materials':7,'stone_texture_resolution':4096,'cloth_door_texture_resolution':1024,'height_m':7.99,'width_m':18.0,'front':'Godot +Z','status':'Approved; integrated in the mission at scale 0.78','source':'art_source/gate/v2/gate_authoring_v2.blend','reference':'User-provided balanced2_goal.png (10 November 2026)'}
(OUT/'asset_info.json').write_text(json.dumps(stats,indent=2)+'\n')
print('GATE II COMPLETE',stats,flush=True)
