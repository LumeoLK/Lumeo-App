import React, { useRef, useEffect } from "react";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import { useGLTF, OrbitControls } from "@react-three/drei";
import * as THREE from "three";
import { useGSAP } from "@gsap/react";
import gsap from "gsap";
import MacbookModel16 from "./models/Macbook-16";
import { ScrollTrigger } from "gsap/all";
gsap.registerPlugin(ScrollTrigger);
function GLBScene({
  modelPath,
  position = [0, 0, 0],
  rotation = [0, 0, 0],
  scale = 1,
}) {
  const group = useRef();
  const { scene, animations } = useGLTF(modelPath);
  const mixer = useRef();
  const clock = new THREE.Clock();
  const { camera } = useThree();

  // Play animations
  useEffect(() => {
    if (animations?.length) {
      mixer.current = new THREE.AnimationMixer(scene);
      animations.forEach((clip) => mixer.current.clipAction(clip).play());
    }
  }, [animations, scene]);
  useGSAP(() => {
    const tl = gsap.timeline({
      scrollTrigger: {
        trigger: "#features",
        start: "top top",
        end: "bottom bottom",
        scrub: 1,
        pin: true,
        markers: true,
      },
    });

    if (group.current) {
      tl.to(
        camera.position,
        {
            x: 0,
          y: 0.3,
          //   z: 2,
         
        },
        "<"
      );
      tl.to(
        camera.rotation,
        {
          x: Math.PI / 4,
        },
        "<"
      );
      tl.to(group.current.position, {
        x:-0.5,
        z:0.65,
      },"<")
      tl.to(camera.position,{
        x:0.5,
        z:0.1,
        y:0.3
      })
      //   tl.to(
      //     camera,
      //     {
      //       fov: 15,
      //       duration: 1.5,
      //       onUpdate: () => camera.updateProjectionMatrix(),
      //     },
      //     "<"
      //   );
    }
  }, [camera]);

  useFrame(() => {
    mixer.current?.update(clock.getDelta());
  });

  return (
    <group ref={group} position={position} rotation={rotation} scale={scale}>
      <primitive object={scene} />
    </group>
  );
}

export default function ThreeGLBViewerR3F({
  modelPath = "public/models/model2-transformed.glb",
}) {
  return (
    <section id="features" style={{ width: "100%", height: "200vh" }}>
      <div id="canvas-wrapper" style={{ height: "100vh" }}>
        <Canvas
          className="w-full !h-dvh relative z-40"
          camera={{ position: [7, 4, 3], fov: 20 }}
        >
          <ambientLight intensity={0.5} />
          <directionalLight intensity={1} position={[10, 20, 10]} castShadow />

          <group>
            <GLBScene
              modelPath={modelPath}
              position={[0.5, 0.1, -0.85]}
              rotation={[0, Math.PI / 7, 0]}
              scale={0.825}
            />
          </group>
          <axesHelper args={[5]} />
          <OrbitControls
            enablePan={false}
            enableZoom={false}
            enableRotate={false}
          />
        </Canvas>
      </div>

      <h1>hi</h1>
    </section>
  );
}
