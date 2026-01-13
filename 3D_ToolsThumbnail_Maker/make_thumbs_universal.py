# make_thumbs_universal.py - FINAL VERSION - works on EVERY Windows path
import bpy, os, sys, math

# Get folder safely
if len(sys.argv) >= 2 and sys.argv[-2] == '--':
    folder = sys.argv[-1]
else:
    folder = os.getcwd()

folder = folder.strip('"').strip()
if folder[1:2] == ":" and folder[2:3] != "\\":
    folder = folder[:2] + "\\" + folder[2:]   # Fix D:Downloads → D:\Downloads

print(f"Working in: {folder}")
os.chdir(folder)

count = 0
failed = 0

for root, dirs, files in os.walk(folder):
    for f in files:
        if not f.lower().endswith(('.stl', '.obj.stl')):
            continue
        stl = os.path.join(root, f)
        png = os.path.splitext(stl)[0] + ".png"
        if os.path.exists(png):
            continue

        count += 1
        print(f"[{count:3d}] Rendering: {f}")

        # Clean scene
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete()
        for block in bpy.data.meshes:    bpy.data.meshes.remove(block, do_unlink=True)
        for block in bpy.data.materials: bpy.data.materials.remove(block, do_unlink=True)
        for block in bpy.data.images:    bpy.data.images.remove(block, do_unlink=True)

        # Try import – if it fails, create red cube
        try:
            bpy.ops.wm.stl_import(filepath=stl)
            imported = len(bpy.context.selected_objects) > 0
        except:
            imported = False

        if imported and bpy.context.selected_objects:
            obj = bpy.context.selected_objects[0]
            bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY', center='BOUNDS')
            obj.location = (0,0,0)
            dim = obj.dimensions
            s = 3.2 / max(dim) if max(dim) > 0 else 1
            obj.scale = (s,s,s)
        else:
            # Red cube for broken/empty STL
            bpy.ops.mesh.primitive_cube_add(size=2)
            mat = bpy.data.materials.new("Red")
            mat.diffuse_color = (1, 0.2, 0.2, 1)
            bpy.context.object.data.materials.append(mat)
            failed += 1

        # Camera & light
        if not bpy.context.scene.camera:
            bpy.ops.object.camera_add(location=(7, -7, 5))
            bpy.context.scene.camera = bpy.context.object
        bpy.context.scene.camera.rotation_euler = (1.1, 0, 0.785)
        bpy.ops.object.light_add(type='SUN', location=(5,5,10))
        bpy.context.object.data.energy = 15

        # Render
        sc = bpy.context.scene
        sc.render.engine = 'BLENDER_EEVEE_NEXT'
        sc.render.resolution_x = sc.render.resolution_y = 1080
        sc.render.image_settings.file_format = 'PNG'
        sc.render.filepath = png
        bpy.ops.render.render(write_still=True)

print(f"\nSUCCESS! {count} thumbnails created ({failed} were broken → red cube)")
input("Press Enter to close...")