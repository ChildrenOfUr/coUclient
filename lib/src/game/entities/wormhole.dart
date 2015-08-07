part of couclient;

class Wormhole {

  static Map<String, Wormhole> wormholes = {};

  static void init() {
    /**
     * Structure:
     * wormholes["<NameReadByHumans>"] = new WormHole(<left x>, <top y>, <width>, <height>, "<tsid_of_wormhole>", "<destination_tsid>");
     *
     * Getting values:
     * Use the mapfiller to place a mailbox on the top left and bottom right corners (aligning the top left corner of the
     * mailbox's rectangle), then load up the game and find their CSS x/y transform.
     */

    wormholes["GroddleLadder"] = new Wormhole(2648, -3, 752, 336, "LM4115NJ46G8M", "LLI2VDR4JRD1AEG");
    wormholes["HellDescend"] = new Wormhole(2574, 831, 199, 152, "LA5PPFP86NF2FOS", "LA5PV4T79OE2AOA");
    wormholes["TheEntrance"] = new Wormhole(5714, 465, 243, 100, "LIF102FDNU11314", "LHH101L162117H2");
    wormholes["HoleToIx"] = new Wormhole(218, 639, 194, 196, "LLI2VDR4JRD1AEG", "LM4115NJ46G8M");
    wormholes["WintryPlace"] = new Wormhole(522, -1, 177, 160, "LLI23D3LDHD1FQA", "LM11E7ODKHO1QJE");
  }

  static void updateAll() {
    getStreet().forEach((Wormhole wormhole) {
      if (intersect(wormhole.hitBox, CurrentPlayer.avatarRect)) {
        tp(wormhole.toTSID);
      }
    });
  }

  static void tp(String toTSID) {
    streetService.requestStreet(toTSID);
  }

  static List<Wormhole> getStreet([String TSID]) {
    String street;
    if (TSID != null) {
      street = TSID;
    } else {
      street = currentStreet.tsid;
    }

    return wormholes.values.where((Wormhole wormhole) => wormhole.onTSID.substring(1) == street.substring(1)).toList();
  }

  // Instances ////////////////////////////////////////////////////////////////////////////////////

  int leftX, topY, width, height;
  String onTSID, toTSID;
  Rectangle hitBox;

  Wormhole(this.leftX, this.topY, this.width, this.height, this.onTSID, this.toTSID) {
    hitBox = new Rectangle(leftX, topY, width, height);
  }

  String toString() {
    return "Wormhole to $toTSID located on $onTSID at ($leftX, $topY) $width x $height";
  }
}