"""Original terrain 01. Blender --background --factory-startup --python this_file.
Metres; Blender Z-up, -Y faces the basin (Godot +Z). No downloaded art/add-ons.
Tile PBR is baked before mapping; stable triangulated meshes retain editable forms.
"""
import bpy, bmesh, math, random, json
from pathlib import Path
from mathutils import Vector

SRC = Path(__file__).resolve().parent
ROOT = SRC.parents[1]
OUT = ROOT / 'assets/terrain_study'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version = 0
scene = bpy.context.scene
scene.render.engine = 'CYCLES'; scene.cycles.samples = 4
rng = random.Random(10112026)

def tile(name, source, tint, relief, roughness):
    bpy.ops.mesh.primitive_plane_add(size=2)
    plane = bpy.context.object
    mat = bpy.data.materials.new(name + ' source'); mat.use_nodes = True
    n, l = mat.node_tree.nodes, mat.node_tree.links
    p = n.get('Principled BSDF'); out = n.get('Material Output')
    tex = n.new('ShaderNodeTexImage'); tex.image = bpy.data.images.load(str(source)); tex.image.pack()
    grade = n.new('ShaderNodeMixRGB'); grade.blend_type = 'MULTIPLY'
    grade.inputs[0].default_value = 1; grade.inputs[2].default_value = (*tint,1)
    if name == 'cliff':
        calm=n.new('ShaderNodeMixRGB'); calm.inputs[0].default_value=.27
        calm.inputs[2].default_value=(.43,.30,.20,1)
        l.new(tex.outputs['Color'],calm.inputs[1]); l.new(calm.outputs[0],grade.inputs[1])
    else: l.new(tex.outputs['Color'],grade.inputs[1])
    l.new(grade.outputs[0],p.inputs['Base Color'])
    bump = n.new('ShaderNodeBump'); bump.inputs['Strength'].default_value = .45
    bump.inputs['Distance'].default_value = relief
    l.new(tex.outputs['Color'],bump.inputs['Height']); l.new(bump.outputs[0],p.inputs['Normal'])
    p.inputs['Roughness'].default_value = roughness
    plane.data.materials.append(mat)
    dst = n.new('ShaderNodeTexImage'); emission = n.new('ShaderNodeEmission')
    maps = {}
    for channel in ('albedo','normal','roughness'):
        img = bpy.data.images.new(name+'_'+channel,width=1024,height=1024,alpha=False)
        if channel != 'albedo': img.colorspace_settings.name = 'Non-Color'
        dst.image = img; n.active = dst
        if channel == 'normal': l.new(p.outputs[0],out.inputs['Surface'])
        else:
            if channel == 'albedo': l.new(grade.outputs[0],emission.inputs['Color'])
            else:
                for link in list(emission.inputs['Color'].links): l.remove(link)
                emission.inputs['Color'].default_value = (roughness,roughness,roughness,1)
            l.new(emission.outputs[0],out.inputs['Surface'])
        bpy.ops.object.bake(type='NORMAL' if channel=='normal' else 'EMIT',margin=8)
        img.filepath_raw = str(OUT/(img.name+'.png')); img.file_format='PNG'; img.save(); maps[channel]=img
    bpy.data.objects.remove(plane,do_unlink=True)
    portable = bpy.data.materials.new(name+' portable PBR'); portable.use_nodes=True
    n,l=portable.node_tree.nodes,portable.node_tree.links; p=n.get('Principled BSDF')
    for channel,socket in [('albedo','Base Color'),('roughness','Roughness'),('normal','Normal')]:
        t=n.new('ShaderNodeTexImage'); t.image=maps[channel]; t.image.pack()
        if channel=='normal':
            normal=n.new('ShaderNodeNormalMap'); l.new(t.outputs[0],normal.inputs['Color']); l.new(normal.outputs[0],p.inputs[socket])
        else: l.new(t.outputs[0],p.inputs[socket])
    return portable

sand=tile('sand',SRC/'sand_source.png',(.85,.87,.89),.023,.96)
cliff=tile('cliff',SRC/'cliff_source.png',(.76,.82,.88),.025,.91)
stone=tile('paving',ROOT/'art_source/gate/v2/aged_limestone_source.png',(.83,.84,.80),.045,.88)

def mesh(name,verts,faces,mat,uvs=None,bevel=.035):
    data=bpy.data.meshes.new(name); data.from_pydata(verts,[],faces); data.update()
    obj=bpy.data.objects.new(name,data); scene.collection.objects.link(obj)
    data.materials.append(mat)
    uv=data.uv_layers.new(name='Material metres')
    for p in data.polygons:
        for li in p.loop_indices:
            v=data.vertices[data.loops[li].vertex_index].co
            uv.data[li].uv=uvs[data.loops[li].vertex_index] if uvs else (v.x/3.5,v.y/3.5)
    bpy.ops.object.select_all(action='DESELECT'); obj.select_set(True); bpy.context.view_layer.objects.active=obj
    bm=bmesh.new(); bm.from_mesh(data); bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(data); bm.free()
    if bevel:
        mod=obj.modifiers.new('Eroded fracture edges','BEVEL'); mod.width=bevel; mod.segments=3
        mod.limit_method='ANGLE'; mod.angle_limit=.22; bpy.ops.object.modifier_apply(modifier=mod.name)
        for p in data.polygons: p.use_smooth=True
        mod=obj.modifiers.new('Broad face normals','WEIGHTED_NORMAL'); mod.keep_sharp=True
        bpy.ops.object.modifier_apply(modifier=mod.name)
    mod=obj.modifiers.new('Explicit stable triangles','TRIANGULATE'); bpy.ops.object.modifier_apply(modifier=mod.name)
    return obj

def cliff_mass(name,outline,height,seed):
    """One continuous eroded block: offset strata follow fracture planes, no stacked primitives."""
    r=random.Random(seed); count=len(outline)
    levels=[0,.14,.24,.275,.43,.47,.64,.68,.86,.92,1]
    # Main sloping beds, deeply recessed seam, broken cap. Each face erodes differently.
    profile=[1.05,1.02,.96,1.06,.97,.86,.92,.81,.83,.76,.70]
    shifts=[(0,0),(.04,.03),(.06,.03),(.04,-.05),(.12,.04),(.18,.13),(.12,.12),(.16,.18),(.21,.20),(.25,.25),(.19,.28)]
    recess=[r.uniform(.65,1.3) for _ in outline]
    verts=[]; uvs=[]; faces=[]
    perimeter=[0]
    for i in range(1,count): perimeter.append(perimeter[-1]+Vector(outline[i]).__sub__(Vector(outline[i-1])).length)
    for k,(level,s) in enumerate(zip(levels,profile)):
        for i,(x,y) in enumerate(outline):
            local=1+(s-1)*recess[i]
            z=height*level + (0 if k==0 else .13*x+.09*y+math.sin(i*1.9+seed)*.12)
            verts.append((x*local+shifts[k][0],y*local+shifts[k][1],z))
            uvs.append((perimeter[i]/6+seed*.11,z/6))
    for k in range(len(levels)-1):
        for i in range(count):
            j=(i+1)%count
            faces.append((k*count+i,k*count+j,(k+1)*count+j,(k+1)*count+i))
    # A separate triangulated cap has planar UVs, preventing radial stretched texture.
    top=len(verts)
    verts.extend(verts[-count:]); uvs.extend([(v[0]/6,v[1]/6) for v in verts[top:]])
    center=len(verts); verts.append(tuple(sum(v[c] for v in verts[top:])/count for c in range(3))); uvs.append((verts[-1][0]/6,verts[-1][1]/6))
    for i in range(count): faces.append((center,top+i,top+(i+1)%count))
    faces.append(tuple(range(count-1,-1,-1)))
    return mesh(name,verts,faces,cliff,uvs,.065)

def slab(name,outline,bottom,top,mat=stone,bevel=.035):
    count=len(outline)
    verts=[(x,y,z) for z in (bottom,top) for x,y in outline]
    # Convex outlines allow an explicit fan with no folded strip triangles.
    verts.append((sum(p[0] for p in outline)/count,sum(p[1] for p in outline)/count,top))
    faces=[(2*count,count+i,count+(i+1)%count) for i in range(count)]
    faces += [(i,(i+1)%count,(i+1)%count+count,i+count) for i in range(count)]
    faces.append(tuple(range(count-1,-1,-1)))
    return mesh(name,verts,faces,mat,bevel=bevel)

def join(objects,name):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]; bpy.ops.object.join()
    o=bpy.context.object; o.name=name; return o

outlines=[
 [(-3.8,-1.4),(-2.9,-2.5),(-.6,-2.75),(1.0,-2.35),(2.9,-2.5),(3.8,-1.0),(3.3,2.0),(.7,2.8),(-2.6,2.3),(-4,0)],
 [(-3.4,-1.7),(-2.0,-2.8),(-.2,-2.4),(1.8,-2.9),(3.5,-1.8),(3.7,.5),(2.3,2.5),(-.5,2.8),(-3.3,1.7)],
 [(-3.9,-.8),(-3,-2.2),(-1.2,-2.5),(.3,-1.9),(2.5,-2.5),(3.8,-.7),(3.1,2.5),(0,2.8),(-3.2,1.8)]
]
exports=[]
for variant in range(3):
    pieces=[cliff_mass('Continuous canyon buttress',outlines[variant],8.5+variant*.7,600+variant)]
    # Broken shoulders have independently angled silhouettes, not repeated rings.
    for j,(x,y,h,s) in enumerate([(-2.8,-1.5,4.2,.63),(2.9,-.6,5.8,.66),(.5,-2.7,1.1,.39)]):
        o=cliff_mass('Detached joint and fallen toe',[(a*s,b*s) for a,b in outlines[(variant+j+1)%3]],h,631+variant*10+j)
        o.location=(x,y,-.15); o.rotation_euler.z=(-.21 if j==0 else .24); pieces.append(o)
    for j in range(24):
        x=rng.uniform(-4.7,4.7); y=rng.uniform(-4.6,-2.9); s=rng.uniform(.16,.85)
        outline=[(x+math.cos(a)*s,y+math.sin(a)*s*.7) for a in [0,.9,2.2,3.3,4.7,5.6]]
        pieces.append(slab('Talus fracture',outline,-.08,s*.48,cliff,.045))
    obj=join(pieces,'Canyon buttress %02d'%variant); obj.location.x=variant*18
    exports.append((obj,'cliff_%02d.glb'%variant))

# Road follows the existing route; surfaces stay flush enough for ground-level feet.
pavers=[]
for row in range(24):
    z=-15.4+row*1.35
    for col in range(3):
        if rng.random()<(.12 if z<-8 else .29) or (abs(z)<2.3 and abs(col-1)<1.1):continue
        x=(col-1)*1.14+math.sin(z*.18)*.27
        w=rng.uniform(.93,1.09); d=rng.uniform(1.05,1.26); c=rng.uniform(.08,.19)
        outline=[(-w/2+c,-d/2),(w/2-c/2,-d/2),(w/2,-d/2+c),(w/2,d/2-c),(w/2-c,d/2),(-w/2+c,d/2),(-w/2,d/2-c),(-w/2,-d/2+c)]
        angle=rng.uniform(-.09,.09)
        outline=[(x+a*math.cos(angle)-b*math.sin(angle),-z+a*math.sin(angle)+b*math.cos(angle)) for a,b in outline]
        pavers.append(slab('Worn processional paving',outline,-.10,rng.uniform(.016,.038)))

def clip(poly,nx,ny,d):
    out=[]
    for a,b in zip(poly,poly[1:]+poly[:1]):
        da=a[0]*nx+a[1]*ny-d; db=b[0]*nx+b[1]*ny-d
        if da<=0:out.append(a)
        if (da<0)!=(db<0):
            t=da/(da-db); out.append((a[0]+t*(b[0]-a[0]),a[1]+t*(b[1]-a[1])))
    return out

# Authored footprints of four buried stone courts; no collision or navigation change.
for patch,(cx,cz,rx,rz) in enumerate([(-10,-4,5.1,3.5),(10,-5,5.5,3.6),(-9,8,4.8,3.3),(10,8.8,5.3,3.4)]):
    sites=[(x+rng.uniform(-.40,.40),y+rng.uniform(-.40,.40)) for x in range(-6,7) for y in range(-5,6)]
    for x,y in sites:
        edge=(x/rx)**2+(y/rz)**2
        if edge>1 or rng.random()<(.04 if edge<.65 else .32):continue
        poly=[(x-2,y-2),(x+2,y-2),(x+2,y+2),(x-2,y+2)]
        for a,b in sites:
            if (a,b)==(x,y) or (a-x)**2+(b-y)**2>10:continue
            poly=clip(poly,a-x,b-y,(a*a+b*b-x*x-y*y)/2)
            if not poly:break
        if len(poly)<3:continue
        poly=[(cx+x+(a-x)*.92,-cz+y+(b-y)*.92) for a,b in poly]
        pavers.append(slab('Buried fractured court %d'%patch,poly,-.12,rng.uniform(.004,.029),stone,.022))
exports.append((join(pavers,'Processional road and buried courts'),'paving.glb'))

# Authoring file retains all original geometry and packed portable/source textures.
bpy.ops.object.select_all(action='DESELECT')
bpy.ops.wm.save_as_mainfile(filepath=str(SRC/'terrain_authoring.blend'))
stats={}
for obj,filename in exports:
    bpy.ops.object.select_all(action='DESELECT'); obj.select_set(True); bpy.context.view_layer.objects.active=obj
    loc=obj.location.copy(); obj.location=(0,0,0)
    bpy.ops.export_scene.gltf(filepath=str(OUT/filename),export_format='GLB',use_selection=True,export_tangents=True,export_animations=False,export_cameras=False,export_lights=False)
    obj.location=loc; obj.data.calc_loop_triangles(); stats[filename]=len(obj.data.loop_triangles)
(OUT/'asset_info.json').write_text(json.dumps({'revision':1,'triangles':stats,'source':'art_source/terrain/terrain_authoring.blend','units':'metres','collision':False,'provenance':'Original geometry and built-in imagegen material sources. See TEXTURE_SOURCES.md.'},indent=2)+'\n')
print('TERRAIN COMPLETE',stats,flush=True)
