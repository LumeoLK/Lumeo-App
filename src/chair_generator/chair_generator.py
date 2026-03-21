import bpy

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)

def create_box(name, size, location):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (size[0]/2, size[1]/2, size[2]/2)
    return obj

def generate_chair(p):
    clear_scene()

    # Seat
    seat = create_box(
        "Seat",
        (p["seat_width"], p["seat_depth"], p["seat_thickness"]),
        (0, p["seat_height"], 0)
    )

    # Backrest
    backrest = create_box(
        "Backrest",
        (p["seat_width"], p["back_thickness"], p["back_height"]),
        (
            0,
            p["seat_height"] + p["back_height"]/2,
            -p["seat_depth"]/2 + p["back_thickness"]/2
        )
    )

    # Legs
    offsets = [
        ( 1,  1),
        (-1,  1),
        ( 1, -1),
        (-1, -1),
    ]

    for i, (x, z) in enumerate(offsets):
        create_box(
            f"Leg_{i}",
            (p["leg_size"], p["leg_height"], p["leg_size"]),
            (
                x * p["seat_width"]/2.2,
                p["leg_height"]/2,
                z * p["seat_depth"]/2.2
            )
        )

    print("Chair generated successfully")