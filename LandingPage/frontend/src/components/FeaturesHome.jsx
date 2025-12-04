import React from "react";
import Placement from '../assets/ar-placement.png'
import CardStacker from '../components/CardStacker'

const FeaturesHome = () => {

  const data = [
    {
      title: 'Multistore Platform',
      subtitle: 'Explore various stores',
      backgroundColors: { top: '#FBDA35', bottom: '#E3A237' },
      image: Placement,
    },
    {
      title: 'Customizable furniture',
      subtitle: 'Make it to your own taste',
      backgroundColors: { top: '#FBDA35', bottom: '#E3A237' },
      image: Placement,
    },
    {
      title: 'Visualise with AR',
      subtitle: 'See it in your space',
      backgroundColors: { top: '#FBDA35', bottom: '#E3A237' },
      image: Placement,
    },
    {
      title: 'Find your match',
      subtitle: 'Upload a picture to find similar items',
      backgroundColors: { top: '#FBDA35', bottom: '#E3A237' },
      image: Placement,
    },
    {
      title: 'Match your style',
      subtitle: 'Find furniture that fit your aesthetic',
      backgroundColors: { top: '#FBDA35', bottom: '#E3A237' },
      image: Placement,
    },
  ];

  return (
    <div className="w-screen h-screen overflow-hidden flex items-center justify-center bg-black">
      
     
      <CardStacker data={data} />

    </div>
  );
}

export default FeaturesHome;