import trimesh


class ChairBuilder:
    def __init__(self, scale_cm):
        self.scale = scale_cm

    def build_from_params(self, params):
        meshes = []

        seat = trimesh.creation.box(
            extents=[params["seat"]["width"],
                     params["seat"]["thickness"],
                     params["seat"]["depth"]]
        )
        seat.apply_translation([0, params["seat"]["height"], 0])
        meshes.append(seat)

        back = trimesh.creation.box(
            extents=[params["back"]["width"],
                     params["back"]["height"],
                     params["back"]["thickness"]]
        )
        back.apply_translation([0,
                                params["seat"]["height"] + params["back"]["height"]/2,
                                -params["seat"]["depth"]/2])
        meshes.append(back)

        leg_h = params["legs"]["height"]
        s = params["legs"]["size"]

        offsets = [
            (-params["seat"]["width"]/2, 0, -params["seat"]["depth"]/2),
            ( params["seat"]["width"]/2, 0, -params["seat"]["depth"]/2),
            (-params["seat"]["width"]/2, 0,  params["seat"]["depth"]/2),
            ( params["seat"]["width"]/2, 0,  params["seat"]["depth"]/2),
        ]

        for x, y, z in offsets:
            leg = trimesh.creation.box(extents=[s, leg_h, s])
            leg.apply_translation([x, leg_h/2, z])
            meshes.append(leg)

        return trimesh.util.concatenate(meshes)