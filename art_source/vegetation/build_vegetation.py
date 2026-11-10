"""Balance vegetation candidate 01 / tree revision 03. Blender 5.2, no add-ons.
Run from any directory: blender --background --factory-startup --python this_file
Original botanical geometry, generated surface atlas, mapped/baked portable PBR.
Z up in authoring; glTF converts to Godot Y up. All units metres.
Rebuild overwrites only this study's outputs; preserve manual edits first.
"""
import bpy, math, random, json, struct
from pathlib import Path
from mathutils import Vector

ROOT=Path(__file__).resolve().parents[2]
SRC=Path(__file__).resolve().parent
OUT=ROOT/'assets/vegetation_study'
OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
scene=bpy.context.scene; scene.render.engine='CYCLES'; scene.cycles.samples=8
rng=random.Random(1101026)
Z=Vector((0,0,1))
parts={}; kit='tree'; records=[]; leaves_count={}; orientation=[]

class Mesh:
    def __init__(self): self.v=[]; self.f=[]; self.uv=[]; self.col=[]
    def vertex(self,p,uv=(0,0),color=(1,1,1,1)):
        self.v.append(tuple(p)); self.uv.append(uv); self.col.append(color); return len(self.v)-1
    def build(self,name,mat,collection):
        me=bpy.data.meshes.new(name); me.from_pydata(self.v,[],self.f); me.update()
        ob=bpy.data.objects.new(name,me); collection.objects.link(ob); me.materials.append(mat)
        uv=me.uv_layers.new(name='UVMap'); col=me.color_attributes.new(name='Tint',type='FLOAT_COLOR',domain='CORNER')
        for p in me.polygons:
            p.use_smooth=True
            for li in p.loop_indices:
                vi=me.loops[li].vertex_index; uv.data[li].uv=self.uv[vi]; col.data[li].color=self.col[vi]
        return ob

def geo(surface):
    key=(kit,surface)
    if key not in parts: parts[key]=Mesh()
    return parts[key]

def bez(a,b,c,d,n=12):
    a,b,c,d=map(Vector,(a,b,c,d))
    return [(1-t)**3*a+3*(1-t)**2*t*b+3*(1-t)*t*t*c+t**3*d for t in (i/n for i in range(n+1))]

def sample(path,t):
    q=max(0,min(.999999,t))*(len(path)-1); i=int(q)
    return path[i].lerp(path[i+1],q-i)

def tube(path,r0,r1,surface='bark',sides=7,color=(1,1,1,1)):
    g=geo(surface); rings=[]; distance=0
    for i,p in enumerate(path):
        if i: distance+=(p-path[i-1]).length
        tangent=(path[min(i+1,len(path)-1)]-path[max(i-1,0)]).normalized()
        guide=Z if abs(tangent.z)<.94 else Vector((0,1,0))
        u=tangent.cross(guide).normalized(); v=tangent.cross(u).normalized()
        r=r0+(r1-r0)*i/(len(path)-1); ring=[]
        for j in range(sides+1):
            a=j*math.tau/sides
            ring.append(g.vertex(p+r*(u*math.cos(a)+v*math.sin(a)),(j/sides*max(.12,r0*math.tau/.65),distance/.65),color))
        rings.append(ring)
    for a,b in zip(rings,rings[1:]):
        for j in range(sides): g.f.append((a[j],a[j+1],b[j+1],b[j]))
    g.f.extend([tuple(reversed(rings[0][:-1])),tuple(rings[-1][:-1])])

def atlas(u,v,q):
    # Source order: top left leaf, top right straw, bottom left rosette, bottom right petal.
    x=[0,.5,0,.5][q]; y=[.5,.5,0,0][q]
    return (x+.009+u*.482,y+.009+v*.482)

def blade(origin,direction,length,width,q=0,tint=(1,1,1),roll=0,curl=.09,thick=0,petal=False,normal_hint=None):
    """Asymmetric curved lamina; correct upper winding, continuous basal petiole junction.
    True tapered endpoints, broadest below middle, fine bent tip, no card outline.
    """
    origin=Vector(origin); forward=Vector(direction).normalized()
    right=forward.cross(Z if normal_hint is None else normal_hint).normalized()
    if right.length<.1: right=Vector((1,0,0))
    up=right.cross(forward).normalized()
    right,up=right*math.cos(roll)+up*math.sin(roll),up*math.cos(roll)-right*math.sin(roll)
    g=geo('botanical'); rows=[]; segments=8 if thick or petal else 6
    for i in range(segments+1):
        t=i/segments
        # Pointed elliptic blade; petals broaden towards their rounded outer margin.
        profile=math.sin(math.pi*t)**(.62 if petal else .82)
        if petal: profile*=.55+.65*t
        center=origin+forward*length*t+up*length*(curl*math.sin(math.pi*t)-.055*t*t)
        row=[]
        for j,s in enumerate((-1,0,1)):
            asym=1+.085*math.sin(4*t+1.2)*(1 if s>0 else -1)
            p=center+right*width*profile*s*asym+up*length*.028*profile*(1-abs(s))
            row.append(g.vertex(p,atlas(j/2,t,q),(*tint,1)))
        rows.append(row)
    for a,b in zip(rows,rows[1:]):
        for j in range(2):
            face=(a[j+1],b[j+1],b[j],a[j]); g.f.append(face)
            normal=(Vector(g.v[face[1]])-Vector(g.v[face[0]])).cross(Vector(g.v[face[2]])-Vector(g.v[face[0]]))
            if normal.length>.000001: orientation.append(normal.normalized().dot(up))
    if thick:
        # Fleshy rosettes have a real underside and sealed perimeter, not flat cards.
        underside=[]
        for i,row in enumerate(rows):
            t=i/segments; lower=[]
            for vi in row: lower.append(g.vertex(Vector(g.v[vi])-up*thick*math.sin(math.pi*t),g.uv[vi],(*[v*.80 for v in tint],1)))
            underside.append(lower)
        for a,b in zip(underside,underside[1:]):
            for j in range(2): g.f.append((a[j],b[j],b[j+1],a[j+1]))
        for i in range(segments):
            for j in (0,2):
                face=(rows[i][j],underside[i][j],underside[i+1][j],rows[i+1][j])
                g.f.append(face if j==0 else face[::-1])
    leaves_count[kit]=leaves_count.get(kit,0)+1

def attach(parent,t,direction,length,width,tint,roll=0):
    """Every leaf petiole begins on the same sampled polyline used to build its twig."""
    node=sample(parent,t); direction=Vector(direction).normalized()
    neck=length*rng.uniform(.13,.21)
    endpoint=node+direction*neck+Z*.012
    path=bez(node,node+direction*neck*.32,node.lerp(endpoint,.78),endpoint,2)
    tube(path,.0038,.0018,'stem',4)
    blade(endpoint,direction,length,width,tint=tint,roll=roll,curl=rng.uniform(.035,.13))
    records.append({'kit':kit,'type':'petiole','gap':(path[0]-sample(parent,t)).length,'blade_gap':(path[-1]-endpoint).length})

def shoot(parent,t,direction,length,count=12,leaf_scale=1):
    start=sample(parent,t); end=start+Vector(direction).normalized()*length
    path=bez(start,start.lerp(end,.32)+Z*.055,start.lerp(end,.75)+Z*.06,end,10)
    tube(path,.011*leaf_scale,.0018,'bark',6)
    records.append({'kit':kit,'type':'shoot','gap':(path[0]-sample(parent,t)).length})
    axis=(end-start).normalized(); side=axis.cross(Z).normalized()
    tint=rng.choice([(.27,.48,.34),(.36,.59,.40),(.43,.64,.50),(.32,.53,.46),(.49,.69,.53)])
    for j in range(count):
        t=.10+j*.84/count; sign=-1 if j%2 else 1
        direction=(side*sign*rng.uniform(.70,1)+axis*.30+Z*rng.uniform(.12,.75)).normalized()
        length=rng.uniform(.19,.29)*leaf_scale*(1-.33*t)
        attach(path,t,direction,length,length*rng.uniform(.27,.36),tint,roll=rng.uniform(-.4,.4))
    attach(path,.99,axis+Z*.25,.16*leaf_scale,.047*leaf_scale,tint)
    return path

# The accepted bowed trunk/root character is retained; all upper branch attachment is rebuilt.
trunk=bez((0,0,.02),(-.30,.06,.70),(.30,-.03,1.60),(.16,.04,2.62),24)
tube(trunk,.29,.035,sides=14)
for a in (.1,1.6,2.8,4.2,5.4):
    radial=Vector((math.cos(a),math.sin(a),0))
    path=bez((0,0,.28),radial*.23+Z*.15,radial*.70+Z*.035,radial*.98+Z*.008,10)
    tube(path,.115,.004,sides=9)
crowns=[(-.82,.18,2.60),(.78,.32,3.10),(.23,-.86,2.75),(.08,.88,2.82),(-.50,-.33,3.27)]
for ci,center in enumerate(crowns):
    center=Vector(center); base=sample(trunk,.56+ci*.075)
    main=bez(base,base.lerp(center,.4)-Z*.14,center-Z*.23,center,14)
    tube(main,.12-ci*.009,.022,sides=10)
    for j in range(8):
        angle=j*2.39996+ci*.79; rad=Vector((math.cos(angle),math.sin(angle),0))
        start=sample(main,.56+j*.052)
        end=center+rad*rng.uniform(.62,1.0)+Z*rng.uniform(-.04,.30)
        branch=bez(start,start.lerp(end,.35)-Z*.08,start.lerp(end,.73)+Z*.08,end,12)
        tube(branch,.025,.004,sides=7)
        records.append({'kit':kit,'type':'branch','gap':(start-sample(main,.56+j*.052)).length})
        for k in range(3):
            a=angle+(k-1)*.72+rng.uniform(-.15,.15)
            shoot(branch,.40+k*.27,(math.cos(a),math.sin(a),rng.uniform(.18,.55)),rng.uniform(.53,.80),count=13)

def bud(center,axis,size):
    """Closed tapered bud with five overlapping sepal ridges and petal core."""
    axis=Vector(axis).normalized(); side=axis.cross(Vector((0,1,0))).normalized(); up=axis.cross(side)
    g=geo('botanical'); rings=[]
    for i in range(8):
        t=i/7; radius=size*.30*math.sin(math.pi*t)**.75
        ring=[]
        for j in range(15):
            a=j*math.tau/15; rr=radius*(1+.10*math.cos(a*5))
            ring.append(g.vertex(center+axis*size*t+rr*(side*math.cos(a)+up*math.sin(a)),atlas(j/15,t,3),(.90,.82,.65,1)))
        rings.append(ring)
    for a,b in zip(rings,rings[1:]):
        for j in range(15): g.f.append((a[j],a[(j+1)%15],b[(j+1)%15],b[j]))
    for j in range(5):
        a=j*math.tau/5; radial=side*math.cos(a)+up*math.sin(a)
        blade(center,axis*.9+radial*.23,size*.67,size*.10,q=0,tint=(.54,.65,.38),curl=.10)

def flower(center,axis,size):
    axis=Vector(axis).normalized(); side=axis.cross(Vector((0,1,0))).normalized(); up=axis.cross(side)
    # Continuous flared five-lobed corolla: cup to lip, each petal rooted on the cup rim.
    g=geo('botanical'); rings=[]
    for i in range(6):
        t=i/5; row=[]
        for j in range(26):
            a=j*math.tau/25; radial=side*math.cos(a)+up*math.sin(a)
            r=size*(.13+.24*t*t); p=center+axis*size*.42*t+radial*r
            row.append(g.vertex(p,atlas(j/25,t*.45,3),(1,.94,.82,1)))
        rings.append(row)
    for a,b in zip(rings,rings[1:]):
        for j in range(25): g.f.append((a[j],a[j+1],b[j+1],b[j]))
    for j in range(5):
        a=j*math.tau/5; radial=side*math.cos(a)+up*math.sin(a)
        blade(center+axis*size*.34+radial*size*.25,radial*.88+axis*.46,size*.76,size*.28,q=3,tint=(1,.96,.87),curl=.22,petal=True,normal_hint=axis)
        blade(center-axis*size*.05,radial*.5+axis*.65,size*.35,size*.075,q=0,tint=(.52,.63,.32))
        # Five fine stamens with modeled elongated anther tips, not a large central lump.
        p=center+axis*size*.22+radial*size*.07; tip=center+axis*size*.71+radial*size*.18
        tube([p,tip],.0025,.0015,'stem',4,color=(.9,.73,.32,1))
        tube([tip-axis*.009,tip+axis*.012],.005,.003,'pollen',6)

def rosette(center,size,flowers=True):
    center=Vector(center)
    for layer,count in enumerate((9,7,5)):
        for j in range(count):
            a=j*math.tau/count+layer*1.15; length=size*(.54-layer*.115)*rng.uniform(.9,1.12)
            direction=Vector((math.cos(a),math.sin(a),.32+layer*.55))
            blade(center+Z*layer*.025,direction,length,length*.19,q=2,tint=(.78,.91,.85),curl=.12,thick=.022*size)
    if not flowers:return
    for j in range(3):
        a=j*2.3; end=center+Vector((math.cos(a)*.12,math.sin(a)*.12,size*(.66+j*.10)))
        stem=bez(center,center.lerp(end,.33)+Vector((.045,0,0)),center.lerp(end,.78),end,12)
        tube(stem,.012*size,.0035*size,'stem',6)
        for k in range(3):
            t=.55+k*.15; angle=a+k*2.39996; radial=Vector((math.cos(angle),math.sin(angle),0))
            p=sample(stem,t); axis=(radial*.65+Z*.78).normalized(); tip=p+axis*.095*size
            tube([p,p.lerp(tip,.55),tip],.005*size,.002*size,'stem',5)
            if k==2:bud(tip,axis,.082*size)
            else:flower(tip,axis,.13*size)
        bud(end,Z,.074*size)

# New root botanical geometry is part of the tree, as in the accepted layout.
rosette((-.65,-.55,.02),.68)
rosette((.43,-.73,.02),.55)

def grass(seed,tall):
    local=random.Random(seed)
    for i in range(54 if tall else 37):
        a=local.uniform(0,math.tau); radial=Vector((math.cos(a),math.sin(a),0)); side=Vector((-radial.y,radial.x,0))
        h=local.uniform(.38,.84) if tall else local.uniform(.18,.42)
        base=radial*local.uniform(.015,.17)
        # Deliberate arched centreline, folded cross section, narrowing tip and asymmetric bends.
        end=base+radial*local.uniform(.18,.45)+Z*h*.65
        path=bez(base,base+radial*.06+Z*h*.60,base+radial*.22+Z*h*1.12,end,12)
        g=geo('botanical'); rows=[]; width=local.uniform(.007,.016)
        tint=local.choice([(.46,.48,.41),(.62,.58,.46),(.33,.44,.35),(.56,.52,.45)])
        for j,p in enumerate(path):
            t=j/(len(path)-1); w=width*(math.sin(math.pi*(.10+.90*t))**.72)
            row=[]
            for k,s in enumerate((-1,0,1)):
                row.append(g.vertex(p+side*s*w+radial*(1-abs(s))*w*.28,atlas(k/2,t,1),(*tint,1)))
            rows.append(row)
        for a,b in zip(rows,rows[1:]):
            for j in range(2):g.f.append((a[j+1],b[j+1],b[j],a[j]))
    if tall:
        for i in range(8):
            a=i*2.39996; radial=Vector((math.cos(a),math.sin(a),0)); h=local.uniform(.65,1.0)
            path=bez(radial*.04,radial*.06+Z*h*.4,radial*.14+Z*h*.80,radial*.23+Z*h,12)
            tube(path,.005,.0014,'stem',5,color=(.73,.61,.36,1))
            # Alternating oat-like spikelets anchored to a nodding seed head.
            for j in range(9):
                p=sample(path,.66+j*.035); sign=1 if j%2 else -1
                tip=p+radial*.032*sign+Z*.035
                tube([p,tip],.0018,.001,'stem',4,color=(.8,.7,.4,1))
                blade(tip,radial*.3*sign+Z,.043,.011,q=1,tint=(.82,.74,.48),curl=.08)

for kit,seed,tall in [('grass_tall',48,True),('grass_low',161,False),('grass_arching',398,True)]: grass(seed,tall)
kit='shrub'
for i in range(11):
    a=i*2.39996; rad=Vector((math.cos(a),math.sin(a),0)); h=rng.uniform(.50,.88)
    branch=bez((0,0,0),rad*.13+Z*h*.38,rad*.29+Z*h*.78,rad*.43+Z*h,12)
    tube(branch,.024,.003,sides=7)
    for j in range(4):
        angle=a+(j%2*2-1)*.7
        shoot(branch,.32+j*.19,(math.cos(angle),math.sin(angle),.45),rng.uniform(.22,.38),count=7,leaf_scale=.59)
kit='crevice_flower'; rosette((0,0,.008),.90)
kit='rosette'; rosette((0,0,.008),.68,False)

def source_material(name,image,bump_distance):
    m=bpy.data.materials.new(name);m.use_nodes=True;n=m.node_tree.nodes;l=m.node_tree.links;p=n.get('Principled BSDF')
    tex=n.new('ShaderNodeTexImage');tex.image=image;l.new(tex.outputs['Color'],p.inputs['Base Color'])
    bw=n.new('ShaderNodeRGBToBW');l.new(tex.outputs[0],bw.inputs[0])
    b=n.new('ShaderNodeBump');b.inputs['Strength'].default_value=.22;b.inputs['Distance'].default_value=bump_distance
    l.new(bw.outputs[0],b.inputs['Height']);l.new(b.outputs[0],p.inputs['Normal'])
    rough=n.new('ShaderNodeMapRange');rough.inputs['To Min'].default_value=.69;rough.inputs['To Max'].default_value=.91
    l.new(bw.outputs[0],rough.inputs[0]);l.new(rough.outputs[0],p.inputs['Roughness'])
    return m

def baked_material(name,source,bump_distance):
    image=bpy.data.images.load(str(source));image.pack();mat=source_material(name+' authoring',image,bump_distance)
    bpy.ops.mesh.primitive_plane_add();sample_obj=bpy.context.object;sample_obj.data.materials.append(mat)
    n=mat.node_tree.nodes;l=mat.node_tree.links;p=n.get('Principled BSDF');out=n.get('Material Output')
    target=n.new('ShaderNodeTexImage');emit=n.new('ShaderNodeEmission');maps={}
    for channel,socket in [('albedo',p.inputs['Base Color'].links[0].from_socket),('normal',None),('roughness',p.inputs['Roughness'].links[0].from_socket)]:
        im=bpy.data.images.new(name+'_'+channel,width=1024,height=1024,alpha=False)
        if channel!='albedo':im.colorspace_settings.name='Non-Color'
        target.image=im;n.active=target
        if channel=='normal':l.new(p.outputs[0],out.inputs[0])
        else:l.new(socket,emit.inputs['Color']);l.new(emit.outputs[0],out.inputs[0])
        bpy.ops.object.bake(type='NORMAL' if channel=='normal' else 'EMIT',margin=4)
        im.filepath_raw=str(OUT/(im.name+'.png'));im.file_format='PNG';im.save();im.pack();maps[channel]=im
        print('BAKED',im.name,flush=True)
    bpy.data.objects.remove(sample_obj,do_unlink=True)
    m=bpy.data.materials.new(name+' PBR');m.use_nodes=True;m.use_backface_culling=False
    n=m.node_tree.nodes;l=m.node_tree.links;p=n.get('Principled BSDF')
    for channel,im in maps.items():
        tex=n.new('ShaderNodeTexImage');tex.image=im
        if channel=='normal':
            normal=n.new('ShaderNodeNormalMap');normal.inputs['Strength'].default_value=.45
            l.new(tex.outputs[0],normal.inputs['Color']);l.new(normal.outputs[0],p.inputs['Normal'])
        elif channel=='albedo':
            vc=n.new('ShaderNodeVertexColor');vc.layer_name='Tint';mul=n.new('ShaderNodeMixRGB');mul.blend_type='MULTIPLY';mul.inputs[0].default_value=1
            l.new(tex.outputs[0],mul.inputs[1]);l.new(vc.outputs['Color'],mul.inputs[2]);l.new(mul.outputs[0],p.inputs['Base Color'])
        else:l.new(tex.outputs[0],p.inputs['Roughness'])
    return m

def solid_material(name,color):
    m=bpy.data.materials.new(name);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value=(*color,1);p.inputs['Roughness'].default_value=.82
    return m

materials={'botanical':baked_material('botanical',SRC/'surface_atlas_source.png',.004),
           'bark':baked_material('bark',ROOT/'art_source/tree/bark_basecolor_source.png',.028),
           'stem':solid_material('Muted living stems',(.17,.23,.075)),
           'pollen':solid_material('Ochre anthers',(.65,.36,.07))}
assets={};collections={};stats={}
for (key,surface),data in parts.items():
    if key not in collections:
        coll=bpy.data.collections.new(key);scene.collection.children.link(coll);collections[key]=coll
    obj=data.build(key+'_'+surface,materials[surface],collections[key]);assets[(key,surface)]=obj
    bpy.context.view_layer.objects.active=obj;obj.select_set(True)
    mod=obj.modifiers.new('Portable triangulation','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=mod.name);obj.select_set(False)

def share_pbr(path):
    # GLB geometry remains binary; shared PNG URIs avoid six copies and Godot extracted duplicates.
    raw=path.read_bytes();size=struct.unpack_from('<I',raw,12)[0];doc=json.loads(raw[20:20+size]);binary=raw[28+size:]
    embedded={im['bufferView'] for im in doc.get('images',[])}
    for im in doc.get('images',[]):
        view=doc['bufferViews'][im.pop('bufferView')];payload=binary[view.get('byteOffset',0):view.get('byteOffset',0)+view['byteLength']]
        name=im['name'].replace('_roughness','_surface')+'.png'
        (OUT/name).write_bytes(payload);im.pop('mimeType',None);im['uri']=name
    packed=bytearray();remap={};views=[]
    for index,view in enumerate(doc['bufferViews']):
        if index in embedded:continue
        packed.extend(b'\0'*((-len(packed))%4));offset=view.get('byteOffset',0)
        payload=binary[offset:offset+view['byteLength']]
        view['byteOffset']=len(packed);remap[index]=len(views);views.append(view);packed.extend(payload)
    for accessor in doc['accessors']:
        if 'bufferView' in accessor:accessor['bufferView']=remap[accessor['bufferView']]
        assert 'sparse' not in accessor
    doc['bufferViews']=views;doc['buffers'][0]['byteLength']=len(packed)
    packed.extend(b'\0'*((-len(packed))%4));binary=bytes(packed)
    js=json.dumps(doc,separators=(',',':')).encode();js+=b' '*((-len(js))%4)
    path.write_bytes(struct.pack('<4sII',b'glTF',2,12+8+len(js)+8+len(binary))+struct.pack('<I4s',len(js),b'JSON')+js+struct.pack('<I4s',len(binary),b'BIN\0')+binary)

for key in collections:
    bpy.ops.object.select_all(action='DESELECT');triangles=0
    for (k,s),obj in assets.items():
        if k==key:obj.select_set(True);obj.data.calc_loop_triangles();triangles+=len(obj.data.loop_triangles)
    bpy.ops.export_scene.gltf(filepath=str(OUT/(key+'.glb')),export_format='GLB',use_selection=True,export_tangents=True,export_vertex_color='NAME',export_vertex_color_name='Tint',export_animations=False,export_cameras=False,export_lights=False)
    share_pbr(OUT/(key+'.glb'));stats[key]={'triangles':triangles,'blades_including_petals':leaves_count.get(key,0)}

# Lay the smaller kit pieces out beside the tree in the editable packed authoring file.
for (key,s),obj in assets.items():
    if key!='tree':obj.location.x=4+list(collections).index(key)*1.8
scene['notes']='Candidate only. Exact petiole/polyline connections. Static geometry; no opacity cards, collisions or gameplay.'
bpy.ops.wm.save_as_mainfile(filepath=str(SRC/'vegetation_authoring.blend'))
assert max(r['gap'] for r in records)<1e-6
assert min(orientation)>.35, 'Upper blade winding reversed or folded through itself'
info={'revision':1,'tree_revision':3,'status':'Accepted for interim use and integrated, 10 November 2026','assets':stats,
      'attachment_records':len(records),'max_centerline_attachment_gap':max(r['gap'] for r in records),
      'minimum_lamina_normal_dot_local_up':min(orientation),'collision':False,'animated':False,
      'source':'art_source/vegetation/vegetation_authoring.blend','provenance':'Original geometry and built-in imagegen atlas; accepted original bark source reused. See TEXTURE_SOURCES.md.'}
(OUT/'asset_info.json').write_text(json.dumps(info,indent=2)+'\n')
diagnostics=ROOT/'artifacts/vegetation';diagnostics.mkdir(parents=True,exist_ok=True)
(diagnostics/'attachment_audit.json').write_text(json.dumps({'summary':info,'attachments':records},indent=2)+'\n')
print('VEGETATION COMPLETE',json.dumps(info),flush=True)
