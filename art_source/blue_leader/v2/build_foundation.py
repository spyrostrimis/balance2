"""Anatomical foundation evaluation using MPFB's CC0 core assets.
Run with Blender --background --factory-startup --python this_file.
The authoring add-on is loaded from an isolated checkout, not installed globally.
"""
import bpy, sys, math, json
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'artifacts/blue_leader/v2';OUT.mkdir(parents=True,exist_ok=True)
TOOL=ROOT/'artifacts/tooling/mpfb2'
SYSTEM=ROOT/'artifacts/tooling/makehuman-system'
sys.path.insert(0,str(TOOL/'src'))
import addon_utils
# Isolated source checkout: route only this add-on's extension storage into
# artifacts instead of registering a persistent Blender extension repository.
_extension_user=bpy.utils.extension_path_user
def _local_extension_user(package,*,path='',create=False):
    if package!='mpfb':return _extension_user(package,path=path,create=create)
    dest=ROOT/'artifacts/tooling/mpfb-user'/path
    if create:dest.mkdir(parents=True,exist_ok=True)
    return str(dest)
bpy.utils.extension_path_user=_local_extension_user
addon_utils.enable('mpfb',default_set=True,persistent=False)
from mpfb.services.humanservice import HumanService
from mpfb.services.targetservice import TargetService
from mpfb.entities.objectproperties import HumanObjectProperties
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
macro=TargetService.get_default_macro_info_dict()
macro.update(gender=0.0,age=.55,muscle=.68,weight=.53,height=.53,proportions=.62,cupsize=.35)
macro['race']={'caucasian':.75,'african':.15,'asian':.10}
body=HumanService.create_human(macro_detail_dict=macro)
body.name='Leader_anatomical_foundation'
targets={'head/head-fat-incr':.08,'head/head-square':.22,'head/head-scale-vert-decr':.06,'mouth/mouth-angles-up':.08,'mouth/mouth-upperlip-volume-incr':.06,'mouth/mouth-lowerlip-volume-incr':.02,'chin/chin-width-incr':.12,'chin/chin-prominent-incr':.10,'nose/nose-scale-vert-incr':.10,'neck/neck-scale-horiz-incr':.12,'eyebrows/eyebrows-trans-down':.15,'eyebrows/eyebrows-angle-down':.12}
for side in ['l','r']:
    targets['eyes/'+side+'-eye-scale-decr']=.12
    targets['cheek/'+side+'-cheek-volume-incr']=.10
for path,amount in targets.items():
    TargetService.load_target(body,str(TOOL/'src/mpfb/data/targets'/(path+'.target.gz')),weight=amount)
HumanService.set_character_skin(str(SYSTEM/'skins/young_caucasian_female/young_caucasian_female.mhmat'),body,skin_type='MAKESKIN')
for path,typ in [('eyes/high-poly/high-poly.mhclo','Eyes'),('eyebrows/eyebrow005/eyebrow005.mhclo','Eyebrows'),('eyelashes/eyelashes01/eyelashes01.mhclo','Eyelashes'),('hair/ponytail01/ponytail01.mhclo','Hair')]:
    asset=HumanService.add_mhclo_asset(str(SYSTEM/path),body,asset_type=typ,subdiv_levels=1)
    asset.name='Leader_'+typ
    if typ=='Eyes':
        for mat in asset.data.materials:
            p=mat.node_tree.nodes.get('Principled BSDF')
            if p:p.inputs['Roughness'].default_value=.18
for mat in body.data.materials:
    if not mat.use_nodes:continue
    nodes=mat.node_tree.nodes;links=mat.node_tree.links
    p=next((n for n in nodes if n.type=='BSDF_PRINCIPLED'),None)
    if p and p.inputs['Base Color'].is_linked:
        source=p.inputs['Base Color'].links[0].from_socket
        tint=nodes.new('ShaderNodeMixRGB');tint.blend_type='MULTIPLY';tint.inputs[0].default_value=1;tint.inputs[2].default_value=(.72,.56,.43,1)
        links.new(source,tint.inputs[1]);links.new(tint.outputs[0],p.inputs['Base Color'])
        p.inputs['Roughness'].default_value=.52
for poly in body.data.polygons:poly.use_smooth=True
mod=body.modifiers.new('Anatomical surface subdivision','SUBSURF');mod.levels=2
rig=HumanService.add_builtin_rig(body,'default')
rig.name='Leader_fitted_rig'
scene=bpy.context.scene
scene.render.engine='CYCLES';scene.cycles.samples=32;scene.cycles.use_denoising=True
scene.render.resolution_x=1200;scene.render.resolution_y=1200;scene.render.resolution_percentage=100
scene.world.color=(.16,.16,.16)
scene.view_settings.view_transform='AgX'
def light(name,loc,power,size,color):
    data=bpy.data.lights.new(name,'AREA');data.energy=power;data.shape='DISK';data.size=size;data.color=color
    o=bpy.data.objects.new(name,data);scene.collection.objects.link(o);o.location=loc;o.rotation_euler=(Vector((0,0,1.5))-o.location).to_track_quat('-Z','Y').to_euler()
light('Large neutral key',(-2,-3,3),150,2.5,(1,.91,.82))
light('Soft fill',(2,-1,2),90,2.0,(.8,.9,1))
light('Hair rim',(1,2,2.5),160,1.5,(1,.9,.75))
data=bpy.data.cameras.new('Review camera');cam=bpy.data.objects.new('Review camera',data);scene.collection.objects.link(cam);scene.camera=cam
cam.data.type='ORTHO';cam.data.ortho_scale=.60;cam.data.lens=70
bpy.context.view_layer.update()
print('BODY_BOUNDS',tuple(body.dimensions),tuple(body.location),flush=True)
for b in rig.data.bones:
    if any(x in b.name for x in ['head','neck','shoulder','upperarm']):print('BONE',b.name,tuple(b.head_local),tuple(b.tail_local),flush=True)
head=rig.data.bones.get('head');focus=rig.matrix_world@head.head_local if head else Vector((0,0,1.6))
focus.z-=.035
for label,angle in [('front',0),('threequarter',-.55),('profile',-1.35)]:
    cam.location=focus+Vector((math.sin(angle)*3,-math.cos(angle)*3,.025));cam.rotation_euler=(focus-cam.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(OUT/(label+'.png'));bpy.ops.render.render(write_still=True)
cam.location=focus+Vector((-1.5,-3,.03));cam.rotation_euler=(focus-cam.location).to_track_quat('-Z','Y').to_euler()
for img in bpy.data.images:
    if img.source=='FILE':img.pack()
bpy.ops.wm.save_as_mainfile(filepath=str(Path(__file__).resolve().parent/'anatomy_authoring.blend'))
(OUT/'foundation_parameters.json').write_text(json.dumps({'macro':macro,'targets':targets,'mpfb_commit':'d0a32e57a7f915cb2f2b95410e2117648c7bbb7e'},indent=2))
