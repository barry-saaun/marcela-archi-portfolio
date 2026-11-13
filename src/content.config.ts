import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

// Images are found by convention: src/assets/<id>/sketch.png and 01.png, 02.png, ...
const projects = defineCollection({
	loader: glob({ pattern: '*.md', base: './src/content/projects' }),
	schema: z.object({
		order: z.number(),
		title: z.string(),
		summary: z.string(),
		type: z.string(),
		location: z.string(),
		year: z.number(),
	}),
});

export const collections = { projects };
