import os
import cv2
import numpy as np
from blueprint.blueprint_model import BlueprintModel


def main():
    # -------------------------------------------------
    # PATH SETUP
    # -------------------------------------------------
    base_dir = os.path.dirname(os.path.dirname(__file__))
    image_path = os.path.join(
        base_dir,
        "assets",
        "blueprints",
        "chairblueprint1.jpg"
    )

    # -------------------------------------------------
    # INITIALIZE MODEL
    # -------------------------------------------------
    model = BlueprintModel(image_path)

    model.load_image()
    model.preprocess()
    model.split_views()

    # -------------------------------------------------
    # SHOW ORIGINAL IMAGE
    # -------------------------------------------------
    original = cv2.resize(model.image, (800, 800))
    cv2.imshow("1. ORIGINAL BLUEPRINT", original)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    # -------------------------------------------------
    # SHOW FRONT & SIDE VIEWS
    # -------------------------------------------------
    front = cv2.resize(model.views["front"], (350, 350))
    side = cv2.resize(model.views["side"], (350, 350))
    combined = np.hstack([front, side])

    cv2.imshow("2. FRONT (left) | SIDE (right)", combined)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    # -------------------------------------------------
    # EXTRACT DIMENSIONS
    # -------------------------------------------------
    front_w, front_h = model.extract_dimensions("front")
    side_w, _ = model.extract_dimensions("side")

    # -------------------------------------------------
    # COMPUTE SCALE
    # (Assume real chair height = 90 cm)
    # -------------------------------------------------
    model.compute_scale(front_h, real_height_cm=90.0)

    # -------------------------------------------------
    # DRAW FRONT CONTOUR
    # -------------------------------------------------
    front_contour = model.extract_contour("front")
    front_canvas = cv2.cvtColor(model.views["front"], cv2.COLOR_GRAY2BGR)

    cv2.drawContours(front_canvas, [front_contour], -1, (0, 255, 0), 2)
    cv2.putText(
        front_canvas,
        f"FRONT CONTOUR: {len(front_contour)} pts",
        (10, 25),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.6,
        (255, 255, 255),
        2
    )

    cv2.imshow("3. FRONT CONTOUR", front_canvas)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    # -------------------------------------------------
    # DRAW SIDE CONTOUR
    # -------------------------------------------------
    side_contour = model.extract_contour("side")
    side_canvas = cv2.cvtColor(model.views["side"], cv2.COLOR_GRAY2BGR)

    cv2.drawContours(side_canvas, [side_contour], -1, (255, 255, 0), 2)
    cv2.putText(
        side_canvas,
        f"SIDE CONTOUR: {len(side_contour)} pts",
        (10, 25),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.6,
        (255, 255, 255),
        2
    )

    cv2.imshow("4. SIDE CONTOUR", side_canvas)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    # -------------------------------------------------
    # GENERATE 2.5D POINT CLOUD
    # -------------------------------------------------
    point_cloud = model.generate_2_5d_point_cloud()

    print("\nSample 3D points (cm):")
    for p in point_cloud[:10]:
        print(p)

    # -------------------------------------------------
    # SIMPLE VISUAL DEPTH CHECK (2D projection)
    # -------------------------------------------------
    h, w = model.views["front"].shape
    cloud_vis = np.zeros((h, w, 3), dtype=np.uint8)

    z_vals = point_cloud[:, 2]
    z_norm = (z_vals - z_vals.min()) / (np.ptp(z_vals) + 1e-6)

    for (x, y, z), zn in zip(point_cloud, z_norm):
        px = int(x / model.scale_factor)
        py = int(y / model.scale_factor)

        if 0 <= px < w and 0 <= py < h:
            color = int(zn * 255)
            cloud_vis[py, px] = (255 - color, color, 50)

    cv2.imshow("5. 2.5D DEPTH MAP (COLOR = DEPTH)", cloud_vis)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    # -------------------------------------------------
    # SAVE OUTPUT
    # -------------------------------------------------
    model.save_point_cloud("stage1_chair_pointcloud.txt")

    print("\n STAGE-1 COMPLETE")
    print("You now have a clean, scaled 2.5D point cloud.")


if __name__ == "__main__":
    main()