import React from 'react';

const Card = ({ title, subtitle, rating, backgroundColors, className = "", image, isHovered = false, isAnyHovered = false }) => {
  const { top, bottom } = backgroundColors;
{/* when the card hovers the other cards go for a gradient and background animation */}

  return (
    <div
      className={
        'card relative p-5 rounded-[5%] drop-shadow-[-5px_2px_2px_rgba(0,0,0,0.3)] text-white overflow-hidden min-h-[350px] w-[250px] hover:-translate-y-10 hover:z-30 shadow-lg hover:shadow-2xl transition-all duration-300 '
        + className
      }
      style={{
        background: `linear-gradient(to bottom, ${top}, ${bottom})`,
      }}
    >

      
      <div
        className={
          `absolute inset-0 bg-cover bg-center transition-opacity duration-500 ${isHovered ? 'opacity-100' : 'opacity-0'}`
        }
        style={{
          backgroundImage: `url(${image})`
        }}
      />

      {/* bottom gradient accent: show for hovered card only */}
      <div
        className={`absolute bottom-0 left-0 right-0 h-2/3 bg-gradient-to-t from-yellow-300/60 to-transparent transition-opacity duration-500 ${isHovered ? 'opacity-100' : 'opacity-0'}`}
      />

      {/* dim overlay for non-hovered cards when any card is hovered */}
      <div
        className={`absolute inset-0 bg-black/60 transition-opacity duration-300 z-10 ${isAnyHovered ? (isHovered ? 'opacity-0' : 'opacity-50') : 'opacity-0'}`}
      />

      <div className="relative z-20">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-2xl text-center font-bold mb-0.5">
              {title}
            </h2>
            <p className="text-xs opacity-70">
              {subtitle}
            </p>
          </div>

        </div>
      </div>

    </div>
  );
};

export default Card;