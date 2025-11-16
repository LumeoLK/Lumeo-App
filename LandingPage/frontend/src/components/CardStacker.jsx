import React, { useState } from 'react';
import Card from './Card';

const CardStacker = ({ data }) => {
  const [hoveredIndex, setHoveredIndex] = useState(null);

  return (
    <div className="flex card-stacker py-10">
      {data.map((eachData, index) => (
        <div
          key={index}
          onMouseEnter={() => setHoveredIndex(index)}
          onMouseLeave={() => setHoveredIndex(null)}
        >
          <Card
            title={eachData.title}
            subtitle={eachData.subtitle}
            rating={eachData.rating}
            backgroundColors={eachData.backgroundColors}
            image={eachData.image}
            
           
            isHovered={hoveredIndex === index}
            isAnyHovered={hoveredIndex !== null}

            className={index !== 0 ? '-ml-32 shadow-[-5px_5px_10px_rgba(0,0,0,0.1)]' : ''}
          />
        </div>
      ))}
    </div>
  );
};

export default CardStacker;
