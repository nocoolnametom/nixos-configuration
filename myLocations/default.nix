let self = {
  home = {
    lat = "37.8";
    long = "-122.1";
    timeZone = "America/Los_Angeles";
  };
  work = {
    lat = "37.7";
    long = "-122.3";
    timeZone = "America/Los_Angeles";
  };
  seattle = {
    lat = "47.6";
    long = "-122.3";
    timeZone = "America/Los_Angeles";
  };
  london = {
    lat = "51.5";
    long = "0.1";
    timeZone = "Europe/London";
  };
  boston = {
    lat = "42.3";
    long = "-71.1";
    timeZone = "America/New_York";
  };
  hebron = {
    lat = "43.7";
    long = "-71.7";
    timeZone = "America/New_York";
  };
  orem = {
    lat = "40.2";
    long = "-111.7";
    timeZone = "America/Denver";
  };
}; in location: (overlaySelf: super: {
    myLocations = {
      inherit (self) home work london boston hebron orem;
    };
    myLocation = self."${location}";
  })
