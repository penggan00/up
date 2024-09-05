export default {
  async fetch(request) {
    /**
     * Replace `remote` with the host you wish to send requests to
     */
    const remote = "https://epg.112114.xyz/pp.xml";

    return await fetch(remote, request);
  },
};