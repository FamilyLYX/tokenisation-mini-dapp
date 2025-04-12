import Image from "next/image";
import familyLogoSVG from "../../public/assets/family_logo.svg";

const FamilyLogo = () => {
  return (
    <Image
      src={familyLogoSVG}
      alt="Family Logo"
      layout="responsive"
      width={192}
      height={96}
      className="z-0"
    />
  );
};

export default FamilyLogo;
