<template>
  <fab
    bg-color="#c6b29b"
    position="bottom-right"
    icon-size="small"
    :actions="actions"
    @binder="binder"
    @nbview="nbview"
  ></fab>
</template>

<script>
import fab from 'vue-fab'

export default {
  name: "Binder",
  props: {
    filepath: String
  },
  components: {
    fab
  },
  data: () => ({
    actions: [{
      name: 'binder',
      icon: 'play_arrow',
      tooltip: 'Run in Binder',
      color: '#282c34'
    }, {
      name: 'nbview',
      icon: 'article',
      tooltip: 'View notebook',
      color: '#297abd'
    }]
  }),
  methods: {
    openInNewTab(url) {
      var newTab = window.open();
        newTab.opener = null;
        newTab.location = url;
    },
    binder() {
      const url = `https://mybinder.org/v2/gh/baking-bad/michelson-labs/master?filepath=${this.filepath}`;
      return this.openInNewTab(url);
    },
    nbview() {
      const url = `https://nbviewer.jupyter.org/github/baking-bad/michelson-labs/blob/master/${this.filepath}`;
      return this.openInNewTab(url);
    }
  }
};
</script>

<style>
@import url("https://fonts.googleapis.com/icon?family=Material+Icons");
</style>