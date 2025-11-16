import React from "react";
import Placement from '../assets/ar-placement.png'
import Img2 from '../assets/img2.png'
import Img3 from '../assets/img3.png'
import Img4 from '../assets/img4.png'
import Img5 from '../assets/img5.png'
import CardStacker from '../components/CardStacker'

const FeaturesHome = () => {

  const data = [
    {
      title: 'Kirby',
      subtitle: 'Star Allies',
      rating: '4.7',
      backgroundColors: { top: '#FBDA35', bottom: '#E3A237' },
      image: Placement,
    },
    {
      title: 'Mario',
      subtitle: 'Super Bros',
      rating: '4.8',
      backgroundColors: { top: '#FBDA35', bottom: '#E3A237' },
      image: Img2,
    },
    {
      title: 'Pokemon',
      subtitle: 'Bulbasaur',
      rating: '4.9',
      backgroundColors: { top: '#FBDA35', bottom: '#E3A237' },
      image: Img3,
    },
    {
      title: 'Sonic',
      subtitle: 'Blue Sonic',
      rating: '4.9',
      backgroundColors: { top: '#FBDA35', bottom: '#E3A237' },
      image: Img4,
    },
    {
      title: 'Pokemon',
      subtitle: 'Pikachu',
      rating: '5.0',
      backgroundColors: { top: '#FBDA35', bottom: '#E3A237' },
      image: Img5,
    },
  ];

  return (
    <div className="h-screen overflow-hidden flex items-center justify-center bg-black">
      
     
      <CardStacker data={data} />

    </div>
  );
}

export default FeaturesHome;