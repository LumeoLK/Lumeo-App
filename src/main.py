import os
import cv2
from blueprint.blueprint_model import BlueprintModel


def main():
    # ---- path setup ----
    base_dir = os.path.dirname(os.path.dirname(__file__))
    image_path = os.path.join(base_dir, "assets", "blueprints", "chairblueprint1.jpg")

    blueprint = BlueprintModel(image_path)

    # ---- pipeline ----
    blueprint.load_image()
    blueprint.preprocess()
    blueprint.split_views()

    # ---- basic dimensions ----
    front_w, front_h = blueprint.extract_dimensions("front")
    side_w, side_h = blueprint.extract_dimensions("side")
    top_w, top_h = blueprint.extract_dimensions("top")

    print("\n=== BASIC FURNITURE DIMENSIONS (PIXELS) ===")
    print(f"Width  : {front_w}")
    print(f"Height : {front_h}")
    print(f"Depth  : {side_w}")

    # ==========================================================
    # FRONT CONTOUR (SAFE)
    # ==========================================================
    front_curve = blueprint.extract_contour("front")

    if front_curve is not None and len(front_curve) > 0:
        front_view = blueprint.views["front"]
        front_canvas = cv2.cvtColor(front_view, cv2.COLOR_GRAY2BGR)

        cv2.drawContours(front_canvas, [front_curve], -1, (0, 255, 0), 2)
        cv2.imshow("Front Curve", front_canvas)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
    else:
        print("⚠️ Front contour not detected")

    # ==========================================================
    # FRONT PART SEGMENTATION (ONCE)
    # ==========================================================
    parts = blueprint.segment_front_parts()

    front_view = blueprint.views["front"]
    canvas = cv2.cvtColor(front_view, cv2.COLOR_GRAY2BGR)

    colors = {
        "backrest": (255, 0, 0),  # Blue
        "seat": (0, 255, 0),      # Green
        "legs": (0, 0, 255)       # Red
    }

    for part, contours in parts.items():
        if contours:
            cv2.drawContours(canvas, contours, -1, colors[part], 2)

    cv2.imshow("Front Segmentation", canvas)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    # ==========================================================
    # FRONT PART DIMENSIONS (FILTERED)
    # ==========================================================
    part_dims = blueprint.extract_front_part_dimensions()

    # ---- SCALE CALCULATION ----
    seat_px_height = part_dims["seat"]["height"]

    REAL_SEAT_HEIGHT_CM = 45  # industry standard

    scale = blueprint.compute_scale(seat_px_height, REAL_SEAT_HEIGHT_CM)

    print("\n=== REAL WORLD DIMENSIONS (CM) ===")
    print(f"Chair Width  : {front_w * scale:.1f} cm")
    print(f"Chair Height : {front_h * scale:.1f} cm")
    print(f"Chair Depth  : {side_w * scale:.1f} cm")


    print("\n=== FRONT VIEW PART DIMENSIONS (PIXELS) ===")
    for part, d in part_dims.items():
        if d["width"] > 0 and d["height"] > 0:
            print(f"{part.upper():10s} | width={d['width']}  height={d['height']}")

    
    front_curve = blueprint.extract_contour("front")
    side_curve = blueprint.extract_contour("side")

    front_real = blueprint.contour_to_real_coords(front_curve, scale)
    side_real = blueprint.contour_to_real_coords(side_curve, scale)

    print(f"\nFront curve real points: {len(front_real)}")
    print(f"Side curve real points : {len(side_real)}")


    # ==========================================================
    # SIDE CONTOUR
    # ==========================================================
    side_curve = blueprint.extract_contour("side")

    if side_curve is not None and len(side_curve) > 0:
        side_view = blueprint.views["side"]
        side_canvas = cv2.cvtColor(side_view, cv2.COLOR_GRAY2BGR)

        cv2.drawContours(side_canvas, [side_curve], -1, (255, 255, 0), 2)
        cv2.imshow("Side Curve", side_canvas)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
    else:
        print("⚠️ Side contour not detected")


if __name__ == "__main__":
    main()
