notes = {
    C:261.6256,
    D:294.6648,
    E:329.6276,
    F:349.2282,
    G:391.9954,
    A:440.0000,
    B:493.8833
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

module.exports = { notes };
