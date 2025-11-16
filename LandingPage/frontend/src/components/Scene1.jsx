import React, { useRef, useEffect } from "react";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import { useGLTF, OrbitControls } from "@react-three/drei";
import * as THREE from "three";

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

  // Play animations
  useEffect(() => {
    if (animations?.length) {
      mixer.current = new THREE.AnimationMixer(scene);
      animations.forEach((clip) => mixer.current.clipAction(clip).play());
    }
  }, [animations, scene]);

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
    <section id="features" style={{ width: "100%", height: "100vh" }}>
      <Canvas
        className="w-full !h-dvh relative z-40"
        camera={{ position: [7, 4, 3], fov: 20 }}
      >
        <ambientLight intensity={0.5} />
        <directionalLight intensity={1} position={[10, 20, 10]} castShadow />
        

        <GLBScene
          modelPath={modelPath}
          position={[0.5, -0.1, -0.85]}
          rotation={[0, Math.PI / 7, 0]}
          scale={0.825}
        />
      </Canvas>
    </section>
  );
}
