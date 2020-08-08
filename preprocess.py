from nbconvert.preprocessors import Preprocessor
from nbformat import NotebookNode
from os.path import join


class RemoveExerciceCells(Preprocessor):

    def preprocess(self, notebook, resources):
        executable_cells = []
        for cell in notebook.cells:
            if cell.cell_type == 'markdown':
                exerc_idx = cell.source.find('## Exerc')
                if exerc_idx != -1:
                    if exerc_idx > 0:
                        cell.source = cell.source[:exerc_idx]
                    break
            elif cell.cell_type == 'code':
                if not cell.source:
                    continue              
            executable_cells.append(cell)
        notebook.cells = executable_cells
        return notebook, resources


class AddBinderComponent(Preprocessor):

    def preprocess(self, notebook, resources):
        filepath = join(resources['metadata']['path'], resources['metadata']['name']) + '.ipynb'
        notebook.cells.append(NotebookNode(
            cell_type='markdown',
            metadata={},
            source=f'<Binder filepath="{filepath}" />'
        ))
        return notebook, resources
