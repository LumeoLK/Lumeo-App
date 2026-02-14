import os
import cv2
from blueprint.blueprint_model import BlueprintModel


def main():
    base_dir = os.path.dirname(os.path.dirname(__file__))
    image_path = os.path.join(base_dir, "assets", "blueprints", "chairblueprint1.jpg")

    blueprint = BlueprintModel(image_path)

    blueprint.load_image()
    blueprint.preprocess()
    blueprint.split_views()

    # ---- dimensions ----
    front_w, front_h = blueprint.extract_dimensions("front")
    side_w, side_h = blueprint.extract_dimensions("side")
    top_w, top_h = blueprint.extract_dimensions("top")

    print("\n=== BASIC FURNITURE DIMENSIONS (PIXELS) ===")
    print(f"Width  : {front_w}")
    print(f"Height : {front_h}")
    print(f"Depth  : {side_w}")

    # ---- extract FRONT contour (THIS WAS MISSING / BROKEN) ----
    front_curve = blueprint.extract_contour("front")

    # ---- draw ONLY on front view ----
    front_view = blueprint.views["front"]
    front_view_color = cv2.cvtColor(front_view, cv2.COLOR_GRAY2BGR)

    cv2.drawContours(front_view_color, [front_curve], -1, (0, 255, 0), 2)

    cv2.imshow("Front Curve", front_view_color)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    parts = blueprint.segment_front_parts()

    front_view = blueprint.views["front"]
    canvas = cv2.cvtColor(front_view, cv2.COLOR_GRAY2BGR)

    colors = {
        "backrest": (255, 0, 0),  # Blue
        "seat": (0, 255, 0),      # Green
        "legs": (0, 0, 255)       # Red
    }

    for part, contours in parts.items():
        cv2.drawContours(canvas, contours, -1, colors[part], 2)

    cv2.imshow("Front Segmentation", canvas)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    part_dims = blueprint.extract_front_part_dimensions()

    print("\n=== FRONT VIEW PART DIMENSIONS (PIXELS) ===")
    for part, d in part_dims.items():
        print(f"{part.upper():10s} | width={d['width']}  height={d['height']}")




if __name__ == "__main__":
    main()
