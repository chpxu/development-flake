{
  python311 = final: prev: {
    python311 = prev.python311.override {
      enableOptimizations = true;
      reproducibleBuild = false;
    };
  };
}
