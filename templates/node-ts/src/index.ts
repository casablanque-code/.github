export function greet(name: string): string {
  return `hello from ${name}`;
}

if (require.main === module) {
  console.log(greet("template-node-ts"));
}
