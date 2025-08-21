// Firebase configuration for the project
// This file helps with Firebase project setup and deployment

module.exports = {
  // Firestore configuration
  firestore: {
    rules: "firestore.rules",
    indexes: "firestore.indexes.json",
  },

  // Functions configuration (if using Cloud Functions)
  functions: {
    source: ".",
    runtime: "nodejs22",
  },

  // Hosting configuration
  hosting: {
    site: "tokenisation",
    public: "out",
    ignore: ["firebase.json", "**/.*", "**/node_modules/**"],
    rewrites: [
      {
        source: "/api/upload",
        function: "nextServer1/api/upload",
      },
    ],
  },
};
