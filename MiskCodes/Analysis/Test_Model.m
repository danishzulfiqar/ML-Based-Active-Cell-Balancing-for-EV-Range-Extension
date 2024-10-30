
loadedData = load('trained_network.mat');
loadedNet = loadedData.net;
predicted_ranges_loaded = loadedNet(X_test);