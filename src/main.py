import os
import numpy as np
from blueprint.blueprint_model import BlueprintModel
from chair_builder import ChairBuilder


def main():
    # -------------------------------------------------
    # ALWAYS RESOLVE PATH FROM THIS FILE LOCATION
    # -------------------------------------------------
    SRC_DIR = os.path.dirname(os.path.abspath(__file__))          # /src
    PROJECT_ROOT = os.path.dirname(SRC_DIR)                       # /LumeoApp

    image_path = os.path.join(
        PROJECT_ROOT,
        "assets",
        "blueprints",
        "chairblueprint1.jpg"
    )

    if not os.path.exists(image_path):
        raise FileNotFoundError(f"Blueprint not found at: {image_path}")

    print("Using blueprint:", image_path)

    # -------------------------------------------------
    # PIPELINE
    # -------------------------------------------------
    model = BlueprintModel(image_path)
    model.load_image()
    model.preprocess()
    model.split_views()

    _, front_h = model.extract_dimensions("front")
    model.extract_dimensions("side")

    model.compute_scale(front_h, real_height_cm=90)

    model.generate_2_5d_point_cloud()
    model.save_point_cloud("stage1_chair_pointcloud.txt")

    dims = model.get_real_dimensions_cm()

    chair_params = {
        "seat": {
            "width": dims["width"],
            "depth": dims["depth"],
            "thickness": 3,
            "height": dims["height"] * 0.45
        },
        "back": {
            "width": dims["width"],
            "height": dims["height"] * 0.55,
            "thickness": 3
        },
        "legs": {
            "size": 4,
            "height": dims["height"] * 0.45
        }
    }

    builder = ChairBuilder(scale_cm=model.scale_factor)
    chair = builder.build_from_params(chair_params)

    chair.export("final_chair.obj")
    print("✅ FULL FEATURE COMPLETE — final_chair.obj created")


if __name__ == "__main__":
    main()