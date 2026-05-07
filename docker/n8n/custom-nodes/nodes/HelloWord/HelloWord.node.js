'use strict';

// ─────────────────────────────────────────────────────────────
//  HelloWorld — minimal custom n8n node template
//  Rename / duplicate this file to build your own nodes.
//  Docs: https://docs.n8n.io/integrations/creating-nodes/
// ─────────────────────────────────────────────────────────────

class HelloWorld {
  constructor() {
    this.description = {
      displayName: 'Hello World',
      name: 'helloWorld',
      group: ['transform'],
      version: 1,
      description: 'A starter custom node — replace with your own logic',
      defaults: {
        name: 'Hello World',
        color: '#1F8A70',
      },
      icon: 'fa:hand-spock',          // FontAwesome icon name
      inputs: ['main'],
      outputs: ['main'],

      // ── Node properties (shown in the UI) ──────────────────
      properties: [
        {
          displayName: 'Greeting',
          name: 'greeting',
          type: 'string',
          default: 'Hello from custom node!',
          placeholder: 'Enter a greeting',
          description: 'The message to add to each item',
          required: true,
        },
        {
          displayName: 'Field Name',
          name: 'fieldName',
          type: 'string',
          default: 'greeting',
          description: 'Key name to store the greeting under in the output',
        },
      ],
    };
  }

  // ── Main execution ────────────────────────────────────────
  async execute() {
    const items = this.getInputData();
    const greeting = this.getNodeParameter('greeting', 0);
    const fieldName = this.getNodeParameter('fieldName', 0);

    const returnData = items.map((item, index) => ({
      json: {
        ...item.json,
        [fieldName]: greeting,
        _node: 'HelloWorld',
        _index: index,
      },
    }));

    return [returnData];
  }
}

module.exports = { HelloWorld };